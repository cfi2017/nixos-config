-- Make the AstroDark colorscheme transparent so the terminal background shows
-- through Neovim (kitty runs at ~90% opacity). AstroNvim configures astrotheme
-- through lazy `opts`, so this table is deep-merged with the core defaults and
-- applied via `require("astrotheme").setup(...)`.
--
-- `float = false` drops the background on `NormalFloat` too. Every Snacks window
-- group ultimately links to `NormalFloat` (SnacksPickerList -> SnacksPicker ->
-- NormalFloat), so this is also what makes the file picker, completion menu and
-- other popups transparent rather than opaque.
---@type LazySpec
return {
  "AstroNvim/astrotheme",
  opts = {
    style = {
      transparent = true,
      -- Both are required to drop the `NormalFloat` background: astrotheme's
      -- float-bg cascade otherwise falls through to a solid colour via the
      -- `border and inactive` branch before it reaches the transparent one.
      float = false,
      inactive = false,
    },
  },
}
