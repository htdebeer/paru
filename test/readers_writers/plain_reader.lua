-- EXAMPLE from https://pandoc.org/custom-readers.html
-- A sample custom reader that just parses text into blankline-separated
-- paragraphs with space-separated words.

-- For better performance we put these functions in local variables:
local P, S, R, Cf, Cc, Ct, V, Cs, Cg, Cb, B, C, Cmt =
  lpeg.P, lpeg.S, lpeg.R, lpeg.Cf, lpeg.Cc, lpeg.Ct, lpeg.V,
  lpeg.Cs, lpeg.Cg, lpeg.Cb, lpeg.B, lpeg.C, lpeg.Cmt

local whitespacechar = S(" \t\r\n")
local wordchar = (1 - whitespacechar)
local spacechar = S(" \t")
local newline = P"\r"^-1 * P"\n"
local blanklines = newline * (spacechar^0 * newline)^1
local endline = newline - blanklines

-- Grammar
G = P{ "Pandoc",
  Pandoc = Ct(V"Block"^0) / pandoc.Pandoc;
  Block = blanklines^0 * V"Para" ;
  Para = Ct(V"Inline"^1) / pandoc.Para;
  Inline = V"Str" + V"Space" + V"SoftBreak" ;
  Str = wordchar^1 / pandoc.Str;
  Space = spacechar^1 / pandoc.Space;
  SoftBreak = endline / pandoc.SoftBreak;
}

function Reader(input)
  return lpeg.match(G, tostring(input))
end
