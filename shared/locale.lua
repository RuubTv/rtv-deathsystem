Locale = Config.Locale or 'en'

function _L(key, ...)
    local lang = Locales[Locale] or Locales['en'] or {}
    local txt = lang[key] or key

    if ... then
        return string.format(txt, ...)
    end

    return txt
end
