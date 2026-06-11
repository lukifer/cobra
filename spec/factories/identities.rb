# frozen_string_literal: true

FactoryBot.define do
  factory :identity do
    name { 'Mr Runner' }
    side { :runner }
    faction { :shaper }
    nrdb_code { '00001' }
    autocomplete { 'Mr Runner' }
  end

  # Corp Ids
  factory :id_ampere, class: 'Identity' do
    name { 'Ampère: Cybernetics For Anyone' }
    side { :corp }
    faction { :neutral_corp }
    nrdb_code { '33128' }
    autocomplete { 'Ampere: Cybernetics For Anyone' }
  end

  factory :id_au_co, class: 'Identity' do
    name { 'AU Co.: The Gold Standard in Clones' }
    side { :corp }
    faction { :jinteki }
    nrdb_code { '35046' }
    autocomplete { 'AU Co.: The Gold Standard in Clones' }
  end

  factory :id_epiphany, class: 'Identity' do
    name { 'Epiphany Analytica: Nations Undivided' }
    side { :corp }
    faction { :nbn }
    nrdb_code { '34048' }
    autocomplete { 'Epiphany Analytica: Nations Undivided' }
  end

  factory :id_etf, class: 'Identity' do
    name { 'Haas-Bioroid: Engineering the Future' }
    side { :corp }
    faction { 'haas-bioroid' }
    nrdb_code { '01054' }
    autocomplete { 'Haas-Bioroid: Engineering the Future' }
  end

  factory :id_nebula, class: 'Identity' do
    name { 'Nebula Talent Management: Making Stars' }
    side { :corp }
    faction { :nbn }
    nrdb_code { '35057' }
    autocomplete { 'Nebula Talent Management: Making Stars' }
  end

  factory :id_ob, class: 'Identity' do
    name { 'Ob Superheavy Logistics: Extract. Export. Excel.' }
    side { :corp }
    faction { 'weyland-consortium' }
    nrdb_code { '33057' }
    autocomplete { 'Ob Superheavy Logistics: Extract. Export. Excel.' }
  end

  factory :id_pd, class: 'Identity' do
    name { 'Haas-Bioroid: Precision Design' }
    side { :corp }
    faction { 'haas-bioroid' }
    nrdb_code { '30035' }
    autocomplete { 'Haas-Bioroid: Precision Design' }
  end

  # Runner Ids
  factory :id_az, class: 'Identity' do
    name { 'Az McCaffrey: Mechanical Prodigy' }
    side { :runner }
    faction { :criminal }
    nrdb_code { '26010' }
    autocomplete { 'Az McCaffrey: Mechanical Prodigy' }
  end

  factory :catalyst_original, class: 'Identity' do
    name { 'The Catalyst: Convention Breaker' }
    side { :runner }
    faction { 'neutral-runner' }
    nrdb_code { '30076' }
    autocomplete { 'The Catalyst: Convention Breaker' }
  end

  factory :catalyst_reprint, class: 'Identity' do
    name { 'The Catalyst: Convention Breaker' }
    side { :runner }
    faction { 'neutral-runner' }
    nrdb_code { '35000' }
    autocomplete { 'The Catalyst: Convention Breaker' }
  end

  factory :id_ari, class: 'Identity' do
    name { 'Arissana Rocha Nahu: Street Artist' }
    side { :runner }
    faction { 'shaper' }
    nrdb_code { '34020' }
    autocomplete { 'Arissana Rocha Nahu: Street Artist' }
  end

  factory :id_esa, class: 'Identity' do
    name { 'Esâ Afontov: Eco-Insurrectionist' }
    side { :runner }
    faction { :anarch }
    nrdb_code { '33001' }
    autocomplete { 'Esa Afontov: Eco-Insurrectionist' }
  end

  factory :id_muslihat, class: 'Identity' do
    name { 'MuslihaT: Multifarious Marketeer' }
    side { :runner }
    faction { :criminal }
    nrdb_code { '35013' }
    autocomplete { 'MuslihaT: Multifarious Marketeer' }
  end

  factory :id_sable, class: 'Identity' do
    name { 'Nyusha "Sable" Sintashta: Symphonic Prodigy' }
    side { :runner }
    faction { :criminal }
    nrdb_code { '33011' }
    autocomplete { 'Nyusha Sable Sintashta: Symphonic Prodigy' }
  end
end
