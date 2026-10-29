"""Encode Nix-generated preferences at build time; merge managed keys on activation."""

import json
import math
import plistlib
import subprocess
import sys


def archive(class_name, fields, extra=()):
    """NSKeyedArchiver representation used by Terminal's font and color fields."""
    return plistlib.dumps({
        "$archiver": "NSKeyedArchiver",
        "$version": 100000,
        "$top": {"root": plistlib.UID(1)},
        "$objects": ["$null", {**fields, "$class": plistlib.UID(2 + len(extra))},
                     *extra, {"$classname": class_name, "$classes": [class_name, "NSObject"]}],
    }, fmt=plistlib.FMT_BINARY)


def rgb(hex_color):
    return [int(hex_color[i:i + 2], 16) / 255 for i in (0, 2, 4)]


def oklch(hex_color):
    r, g, b = [v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4
               for v in rgb(hex_color)]
    l = (0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b) ** (1 / 3)
    m = (0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b) ** (1 / 3)
    s = (0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b) ** (1 / 3)
    lightness = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
    a = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s
    b = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
    return {"wrapped": {"oklch": {
        "chroma": {"kind": {"exact": {"_0": math.hypot(a, b)}}},
        "lightness": {"kind": {"exact": {"_0": lightness}}},
        "hue": {"radiansValue": math.atan2(b, a) % math.tau},
        "gamut": {"sRGB": {}},
        "opacity": 1.0,
    }}}


def encode(value):
    if isinstance(value, list):
        return [encode(item) for item in value]
    if not isinstance(value, dict):
        return value
    if set(value) == {"archiveColor"}:
        components = " ".join(str(v) for v in rgb(value["archiveColor"])) + " 1"
        return plistlib.dumps({
            "$archiver": "NSKeyedArchiver", "$version": 100000,
            "$top": {"root": plistlib.UID(1)},
            "$objects": ["$null", {
                "$class": plistlib.UID(4), "NSColorSpace": 1,
                "NSRGB": (components + "\0").encode(),
                "NSComponents": components.encode(), "NSCustomColorSpace": plistlib.UID(2),
            }, {"$class": plistlib.UID(3), "NSID": 7},
                {"$classname": "NSColorSpace", "$classes": ["NSColorSpace", "NSObject"]},
                {"$classname": "NSColor", "$classes": ["NSColor", "NSObject"]}],
        }, fmt=plistlib.FMT_BINARY)
    if set(value) == {"archiveFont"}:
        font = value["archiveFont"]
        return archive("NSFont", {"NSName": plistlib.UID(2), "NSSize": float(font["size"]),
                                  "NSfFlags": 16}, [font["name"]])
    if set(value) == {"oklchColor"}:
        return oklch(value["oklchColor"])
    if set(value) == {"jsonData"}:
        return json.dumps(encode(value["jsonData"]), sort_keys=True).encode()
    return {key: encode(item) for key, item in value.items()}


def merge(existing, managed):
    result = dict(existing)
    for key, value in managed.items():
        result[key] = merge(result.get(key, {}), value) if isinstance(value, dict) else value
    return result


def apply(settings, dry_run):
    domain = settings["domain"]
    if not dry_run and subprocess.run(
        ["/usr/bin/pgrep", "-x", settings["process"]], capture_output=True
    ).returncode == 0:
        print(f"{settings['process']} is running; quit it and rerun darwin-rebuild switch to apply Stylix.")
        return

    exported = subprocess.run(["/usr/bin/defaults", "export", domain, "-"], capture_output=True)
    current = plistlib.loads(exported.stdout) if exported.returncode == 0 else {}
    updates = dict(settings.get("set", {}))
    for key, value in settings.get("merge", {}).items():
        updates[key] = merge(current.get(key, {}), value)
    for key, value in settings.get("mergeJSON", {}).items():
        updates[key] = json.dumps(merge(json.loads(current.get(key, b"{}")), value), sort_keys=True).encode()
    for key, value in settings.get("upsertJSON", {}).items():
        recipes = json.loads(current.get(key, b"[]"))
        recipes = [item for item in recipes if item.get("id") != value["id"]]
        recipes.append(value)
        updates[key] = json.dumps(recipes, sort_keys=True).encode()

    for key, value in updates.items():
        # A single-key domain import preserves all unrelated preference keys.
        payload = plistlib.dumps({key: value})
        if not dry_run:
            subprocess.run(["/usr/bin/defaults", "import", domain, "-"], input=payload, check=True)
    print(f"{'Validated' if dry_run else 'Applied'} Stylix preferences for {domain}.")


if __name__ == "__main__":
    mode, source, *args = sys.argv[1:]
    with open(source, "rb") as handle:
        settings = json.load(handle) if mode == "render" else plistlib.load(handle)
    if mode == "render":
        with open(args[0], "wb") as handle:
            plistlib.dump(encode(settings), handle)
    elif mode == "apply":
        apply(settings, "--dry-run" in args)
    else:
        raise ValueError(f"Unknown command: {mode}")
