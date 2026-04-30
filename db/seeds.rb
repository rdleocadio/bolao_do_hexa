puts "Iniciando seeds..."

puts "Criando seleções..."

teams_data = [
  { name: "Canadá", code: "can", confederation: "CONCACAF" },
  { name: "Estados Unidos", code: "usa", confederation: "CONCACAF" },
  { name: "México", code: "mex", confederation: "CONCACAF" },

  { name: "Arábia Saudita", code: "ksa", confederation: "AFC" },
  { name: "Austrália", code: "aus", confederation: "AFC" },
  { name: "Catar", code: "qat", confederation: "AFC" },
  { name: "Coreia do Sul", code: "kor", confederation: "AFC" },
  { name: "Irã", code: "irn", confederation: "AFC" },
  { name: "Iraque", code: "irq", confederation: "AFC" },
  { name: "Japão", code: "jpn", confederation: "AFC" },
  { name: "Jordânia", code: "jor", confederation: "AFC" },
  { name: "Uzbequistão", code: "uzb", confederation: "AFC" },

  { name: "África do Sul", code: "rsa", confederation: "CAF" },
  { name: "Argélia", code: "alg", confederation: "CAF" },
  { name: "Cabo Verde", code: "cpv", confederation: "CAF" },
  { name: "Costa do Marfim", code: "civ", confederation: "CAF" },
  { name: "Egito", code: "egy", confederation: "CAF" },
  { name: "Gana", code: "gha", confederation: "CAF" },
  { name: "Marrocos", code: "mar", confederation: "CAF" },
  { name: "RD do Congo", code: "cod", confederation: "CAF" },
  { name: "Senegal", code: "sen", confederation: "CAF" },
  { name: "Tunísia", code: "tun", confederation: "CAF" },

  { name: "Argentina", code: "arg", confederation: "CONMEBOL" },
  { name: "Brasil", code: "bra", confederation: "CONMEBOL" },
  { name: "Colômbia", code: "col", confederation: "CONMEBOL" },
  { name: "Equador", code: "ecu", confederation: "CONMEBOL" },
  { name: "Paraguai", code: "par", confederation: "CONMEBOL" },
  { name: "Uruguai", code: "uru", confederation: "CONMEBOL" },

  { name: "Nova Zelândia", code: "nzl", confederation: "OFC" },

  { name: "Alemanha", code: "ger", confederation: "UEFA" },
  { name: "Áustria", code: "aut", confederation: "UEFA" },
  { name: "Bélgica", code: "bel", confederation: "UEFA" },
  { name: "Bósnia e Herzegovina", code: "bih", confederation: "UEFA" },
  { name: "Croácia", code: "cro", confederation: "UEFA" },
  { name: "Escócia", code: "sco", confederation: "UEFA" },
  { name: "Espanha", code: "esp", confederation: "UEFA" },
  { name: "França", code: "fra", confederation: "UEFA" },
  { name: "Holanda", code: "ned", confederation: "UEFA" },
  { name: "Inglaterra", code: "eng", confederation: "UEFA" },
  { name: "Noruega", code: "nor", confederation: "UEFA" },
  { name: "Portugal", code: "por", confederation: "UEFA" },
  { name: "República Tcheca", code: "cze", confederation: "UEFA" },
  { name: "Suécia", code: "swe", confederation: "UEFA" },
  { name: "Suíça", code: "sui", confederation: "UEFA" },
  { name: "Turquia", code: "tur", confederation: "UEFA" },

  { name: "Curaçau", code: "cuw", confederation: "CONCACAF" },
  { name: "Haiti", code: "hai", confederation: "CONCACAF" },
  { name: "Panamá", code: "pan", confederation: "CONCACAF" }
]

teams_data.each do |data|
  team = Team.find_or_initialize_by(code: data[:code])
  team.name = data[:name]
  team.confederation = data[:confederation]
  team.save!
end

puts "Times cadastrados: #{Team.count}"

def team_by_name(name)
  Team.find_by!(name: name)
end

def create_group_match(home, away, group_code, kickoff_at)
  home_team = team_by_name(home)
  away_team = team_by_name(away)
  parsed_kickoff = Time.zone.parse(kickoff_at)

  match = Match.find_or_initialize_by(
    stage: :group_stage,
    group_code: group_code,
    home_team_id: home_team.id,
    away_team_id: away_team.id,
    kickoff_at: parsed_kickoff
  )

  match.home_team = home_team.name
  match.away_team = away_team.name
  match.save!
end

puts "Criando jogos da fase de grupos..."

# GRUPO A
create_group_match("México", "África do Sul", "A", "2026-06-11 16:00")
create_group_match("Coreia do Sul", "República Tcheca", "A", "2026-06-11 23:00")
create_group_match("República Tcheca", "África do Sul", "A", "2026-06-18 13:00")
create_group_match("México", "Coreia do Sul", "A", "2026-06-18 22:00")
create_group_match("República Tcheca", "México", "A", "2026-06-24 22:00")
create_group_match("África do Sul", "Coreia do Sul", "A", "2026-06-24 22:00")

# GRUPO B
create_group_match("Canadá", "Bósnia e Herzegovina", "B", "2026-06-12 16:00")
create_group_match("Catar", "Suíça", "B", "2026-06-13 16:00")
create_group_match("Suíça", "Bósnia e Herzegovina", "B", "2026-06-18 16:00")
create_group_match("Canadá", "Catar", "B", "2026-06-18 19:00")
create_group_match("Suíça", "Canadá", "B", "2026-06-24 16:00")
create_group_match("Bósnia e Herzegovina", "Catar", "B", "2026-06-24 16:00")

# GRUPO C
create_group_match("Brasil", "Marrocos", "C", "2026-06-13 19:00")
create_group_match("Haiti", "Escócia", "C", "2026-06-13 22:00")
create_group_match("Escócia", "Marrocos", "C", "2026-06-19 19:00")
create_group_match("Brasil", "Haiti", "C", "2026-06-19 21:30")
create_group_match("Marrocos", "Haiti", "C", "2026-06-24 19:00")
create_group_match("Escócia", "Brasil", "C", "2026-06-24 19:00")

# GRUPO D
create_group_match("Estados Unidos", "Paraguai", "D", "2026-06-12 22:00")
create_group_match("Austrália", "Turquia", "D", "2026-06-14 01:00")
create_group_match("Estados Unidos", "Austrália", "D", "2026-06-19 16:00")
create_group_match("Turquia", "Paraguai", "D", "2026-06-20 01:00")
create_group_match("Turquia", "Estados Unidos", "D", "2026-06-25 23:00")
create_group_match("Paraguai", "Austrália", "D", "2026-06-25 23:00")

# GRUPO E
create_group_match("Alemanha", "Curaçau", "E", "2026-06-14 14:00")
create_group_match("Costa do Marfim", "Equador", "E", "2026-06-14 20:00")
create_group_match("Alemanha", "Costa do Marfim", "E", "2026-06-20 17:00")
create_group_match("Equador", "Curaçau", "E", "2026-06-20 21:00")
create_group_match("Equador", "Alemanha", "E", "2026-06-25 17:00")
create_group_match("Curaçau", "Costa do Marfim", "E", "2026-06-25 17:00")

# GRUPO F
create_group_match("Holanda", "Japão", "F", "2026-06-14 17:00")
create_group_match("Suécia", "Tunísia", "F", "2026-06-14 23:00")
create_group_match("Holanda", "Suécia", "F", "2026-06-20 14:00")
create_group_match("Tunísia", "Japão", "F", "2026-06-21 01:00")
create_group_match("Tunísia", "Holanda", "F", "2026-06-25 20:00")
create_group_match("Japão", "Suécia", "F", "2026-06-25 20:00")

# GRUPO G
create_group_match("Bélgica", "Egito", "G", "2026-06-15 16:00")
create_group_match("Irã", "Nova Zelândia", "G", "2026-06-15 22:00")
create_group_match("Bélgica", "Irã", "G", "2026-06-21 16:00")
create_group_match("Nova Zelândia", "Egito", "G", "2026-06-21 22:00")
create_group_match("Egito", "Irã", "G", "2026-06-25 13:00")
create_group_match("Nova Zelândia", "Bélgica", "G", "2026-06-25 13:00")

# GRUPO H
create_group_match("Espanha", "Cabo Verde", "H", "2026-06-15 13:00")
create_group_match("Arábia Saudita", "Uruguai", "H", "2026-06-15 19:00")
create_group_match("Espanha", "Arábia Saudita", "H", "2026-06-21 13:00")
create_group_match("Uruguai", "Cabo Verde", "H", "2026-06-21 19:00")
create_group_match("Cabo Verde", "Arábia Saudita", "H", "2026-06-26 21:00")
create_group_match("Uruguai", "Espanha", "H", "2026-06-26 21:00")

# GRUPO I
create_group_match("França", "Senegal", "I", "2026-06-16 16:00")
create_group_match("Iraque", "Noruega", "I", "2026-06-16 19:00")
create_group_match("França", "Iraque", "I", "2026-06-22 18:00")
create_group_match("Noruega", "Senegal", "I", "2026-06-22 21:00")
create_group_match("Senegal", "Iraque", "I", "2026-06-26 16:00")
create_group_match("Noruega", "França", "I", "2026-06-26 16:00")

# GRUPO J
create_group_match("Argentina", "Argélia", "J", "2026-06-16 22:00")
create_group_match("Áustria", "Jordânia", "J", "2026-06-17 01:00")
create_group_match("Argentina", "Áustria", "J", "2026-06-23 14:00")
create_group_match("Jordânia", "Argélia", "J", "2026-06-23 00:00")
create_group_match("Jordânia", "Argentina", "J", "2026-06-27 23:00")
create_group_match("Argélia", "Áustria", "J", "2026-06-27 23:00")

# GRUPO K
create_group_match("Portugal", "RD do Congo", "K", "2026-06-17 14:00")
create_group_match("Uzbequistão", "Colômbia", "K", "2026-06-17 23:00")
create_group_match("Portugal", "Uzbequistão", "K", "2026-06-23 14:00")
create_group_match("Colômbia", "RD do Congo", "K", "2026-06-23 23:00")
create_group_match("RD do Congo", "Uzbequistão", "K", "2026-06-27 20:30")
create_group_match("Colômbia", "Portugal", "K", "2026-06-27 20:30")

# GRUPO L
create_group_match("Inglaterra", "Croácia", "L", "2026-06-17 17:00")
create_group_match("Gana", "Panamá", "L", "2026-06-17 20:00")
create_group_match("Inglaterra", "Gana", "L", "2026-06-23 17:00")
create_group_match("Panamá", "Croácia", "L", "2026-06-23 20:00")
create_group_match("Croácia", "Gana", "L", "2026-06-27 18:00")
create_group_match("Panamá", "Inglaterra", "L", "2026-06-27 18:00")

def create_knockout_matches(stage, quantity, first_kickoff_at)
  kickoff = Time.zone.parse(first_kickoff_at)

  quantity.times do |index|
    match_time = kickoff + index.days

    match = Match.find_or_initialize_by(
      stage: stage,
      kickoff_at: match_time
    )

    match.home_team = "A definir"
    match.away_team = "A definir"
    match.home_team_id = nil
    match.away_team_id = nil
    match.group_code = nil
    match.save!
  end
end

puts "Criando jogos do mata-mata..."

create_knockout_matches(:second_phase, 16, "2026-06-28 16:00")
create_knockout_matches(:round_of_16, 8, "2026-07-04 16:00")
create_knockout_matches(:quarterfinal, 4, "2026-07-10 16:00")
create_knockout_matches(:semifinal, 2, "2026-07-14 16:00")
create_knockout_matches(:third_place, 1, "2026-07-18 16:00")
create_knockout_matches(:final, 1, "2026-07-19 16:00")

puts "Jogos do mata-mata criados:"
puts "16 avos: #{Match.second_phase.count}"
puts "Oitavas: #{Match.round_of_16.count}"
puts "Quartas: #{Match.quarterfinal.count}"
puts "Semifinais: #{Match.semifinal.count}"
puts "3º lugar: #{Match.third_place.count}"
puts "Final: #{Match.final.count}"


puts "Seeds finalizado 🚀"
puts "Total de seleções: #{Team.count}"
puts "Total de jogos da fase de grupos: #{Match.group_stage.count}"
