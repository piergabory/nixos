"use strict";

// iCloud rejects colon-bearing keywords (Bulwark's $label:* tags) as atoms,
// but accepts them as quoted strings. Preload before ImapFlow imports its
// compiler; keep the workaround scoped to KEYWORD/UNKEYWORD arguments.
const compiler = require("/app/node_modules/imapflow/lib/search-compiler.js");
const searchCompiler = compiler.searchCompiler;

function quoteKeywords(attributes) {
  for (let i = 0; i < attributes.length; i++) {
    const token = attributes[i];
    if (Array.isArray(token)) {
      quoteKeywords(token);
      continue;
    }
    if (token?.type !== "ATOM" || !["KEYWORD", "UNKEYWORD"].includes(token.value)) {
      continue;
    }
    const argument = attributes[++i];
    if (argument?.type === "ATOM" && argument.value.includes(":")) {
      argument.type = "STRING";
    }
  }
  return attributes;
}

compiler.searchCompiler = (...args) => quoteKeywords(searchCompiler(...args));
