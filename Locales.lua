local Locales = {
  enUS = {},
  frFR = {},
  deDE = {},
  ruRU = {},
  ptBR = {},
  esES = {},
  esMX = {},
  zhTW = {},
  zhCN = {},
  koKR = {},
  itIT = {},
}

local L = Locales.enUS
L["REAGENTS_VALUE_COLON_X"] = "Reagents Value: %s"
L["REAGENTS_REQUIRED_COLON"] = "Reagents Required:"
L["MAKES_COLON_X"] = "Makes: %s"
L["PENDING_ELLIPSE"] = "Pending..."

local L = Locales.frFR
--@localization(locale="frFR", format="lua_additive_table")@

local L = Locales.deDE
--@localization(locale="frFR", format="lua_additive_table")@

local L = Locales.ruRU
--@localization(locale="frFR", format="lua_additive_table")@

local L = Locales.esES
--@localization(locale="frFR", format="lua_additive_table")@

local L = Locales.esMX
--@localization(locale="frFR", format="lua_additive_table")@

local L = Locales.zhTW
--@localization(locale="frFR", format="lua_additive_table")@

local L = Locales.zhCN
--@localization(locale="frFR", format="lua_additive_table")@

local L = Locales.koKR
--@localization(locale="frFR", format="lua_additive_table")@

local L = Locales.itIT
--@localization(locale="frFR", format="lua_additive_table")@

CraftInfoAnywhere.Locales = CopyTable(Locales.enUS)
for key, translation in pairs(Locales[GetLocale()]) do
  CraftInfoAnywhere.Locales[key] = translation
end
