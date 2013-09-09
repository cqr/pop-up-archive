require 'pb_core'
require 'yaml'

namespace :languages do

  desc "Generate list of languages and countries to config/languages.yml"
  task export: [:environment] do

    countries_by_lang = Country.all.inject({}) do |ls, n|
      c = Country.find_by_alpha2(n[1])[1]
      c['languages'].each{|l| ls[l] ? ls[l].push(c) : ls[l] = [c] }
      ls
    end

    common = [
      text: 'Common', children: [
        {id: 'en-US', text: 'English (United States)'},
        {id: 'ar-EG', text: 'Arabic (Egypt)'},
        {id: 'zh-CN', text: 'Chinese (China)'},
        {id: 'fr-FR', text: 'French'},
        {id: 'de-DE', text: 'German'},
        {id: 'it-IT', text: 'Italian'},
        {id: 'ja-JA', text: 'Japanese'},
        {id: 'ko-KO', text: 'Korean'},
        {id: 'pt-PT', text: 'Portuguese'},
        {id: 'ru-RU', text: 'Russian'},
        {id: 'es-ES', text: 'Spanish (Spain)'}
      ]
    ]

    languages = LanguageList::COMMON_LANGUAGES.collect do |l|
      countries = countries_by_lang[l.iso_639_1]
      if countries.blank?
        { id: "#{l.iso_639_1}", text: l.name }
      elsif countries.size == 1
        c = countries.first
        code = c['un_locode'] ? "#{l.iso_639_1}-#{c['un_locode']}" : l.iso_639_1
        lang_country = "#{l.name} (#{c['name']})"
        {id: code, text: lang_country }
      else
        {
          text: l.name,
          children: countries.collect do |c|
            next unless c['un_locode']
            code = "#{l.iso_639_1}-#{c['un_locode']}"
            lang_country = "#{l.name} (#{c['name']})"
            {id: code, text: lang_country }
          end.compact
        }
      end
    end
    File.write('public/languages.json', (common + languages).to_json)
  end

end