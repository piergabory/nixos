# Netatmo / Legrand development

Canonical company-wide guidance:
`~/Developer/netatmo/rss/mobile/platform/ai-tooling/instructions/common/AGENTS.md`.
Read it before working here; resolve its supporting documents relative to that
directory.

For Swift or iOS tasks only, also read
`~/Developer/netatmo/rss/mobile/platform/ai-tooling/instructions/ios/AGENTS.md`.
Its supporting documents are relative to the iOS instructions directory.

Company AI tooling and sensitive company data may only be used with GitHub Copilot
under GITHUB-COPILOT-LEGRAND. The provider allowlist does not verify the
authenticated organization; check the account before fetching company data.

# Swift and iOS Developement

Run xcode builds with -skipMacroValidation if you get stuck by "KitMacros".

You can write short ternary expressions, but use inline 'if' expressions 
if they're over 80 characters long or span multiple lines.

Be conservative with the `@entry` macro in `ContainerValue` or `EnvironmentValue`. 
If you need multiple declarations for the same feature, consider grouping them 
under a structure.

On types repeating the `@MainActor` attribute on its members, consider applying it to the whole type, in particular for View-owned types.
