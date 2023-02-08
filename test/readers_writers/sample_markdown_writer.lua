-- EXAMPLE from https://pandoc.org/custom-writers.html
-- This is a sample custom writer for pandoc.  It produces output
-- that is very similar to that of pandoc's GitHub flavour 
-- markdown writer. 
function Writer (doc, opts)
  local filter = {
    CodeBlock = function (cb)
      -- only modify if code block has no attributes
      if cb.attr == pandoc.Attr() then
        local delimited = '```\n' .. cb.text .. '\n```'
        return pandoc.RawBlock('markdown', delimited)
      end
    end
  }
  return pandoc.write(doc:walk(filter), 'gfm', opts)
end
