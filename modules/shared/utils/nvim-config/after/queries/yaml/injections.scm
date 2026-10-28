;; extends

((block_scalar
  (comment) @injection.language) @injection.content
  (#gsub! @injection.language "^#%s*language=(%w+).*" "%1")
  (#offset! @injection.content 0 1 0 0))
