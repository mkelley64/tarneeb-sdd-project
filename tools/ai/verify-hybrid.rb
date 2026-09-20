require 'json'
require 'digest'

def check(condition, message)
  raise message unless condition
end

def interval(values, z)
  mean = values.sum.to_f / values.length
  se = Math.sqrt(values.sum { |v| (v - mean)**2 } / (values.length - 1) / values.length)
  { 'clusters' => values.length, 'mean' => mean, 'lower' => mean - z * se, 'upper' => mean + z * se }
end

reports = ARGV.map do |path|
  r = JSON.parse(File.read(path))
  check(r['protocolID'] == 'hybrid-confirmation-2026-09-19', 'protocol')
  check(r['candidate'] == 'expert' && r['candidateBidding'] == 'advanced', 'candidate')
  check(%w[standard advanced expert].include?(r['reference']), 'reference')
  check(r['firstStream'] == 400000 && r['streams'] == 256, 'stream metadata')
  check(r.values_at('cardSamples','cardMaxTricks','cardBudgetSeconds','bidSamples','bidBudgetSeconds','maxDeals') == [8,13,0.15,16,0.2,256], 'limits')
  records = r.fetch('matches')
  check(records.length == 2048, 'match count')
  groups = records.group_by { |m| m['stream'] }.sort
  check(groups.map(&:first) == (400000..400255).to_a, 'stream coverage')
  expected = (0..3).flat_map { |rotation| %w[teamA teamB].map { |team| [rotation,team] } }
  groups.each { |_, ms| check(ms.map { |m| m.values_at('rotation','candidateTeam') }.sort == expected, 'balanced arrangements') }
  records.each do |m|
    check(m['deals'] == m['playedHands'] + m['allPass'] && m['deals'] <= 256, 'deals')
    check([true,false].include?(m['candidateWon']), 'unresolved match')
    winner, loser = m['candidateWon'] ? m.values_at('candidatePoints','referencePoints') : m.values_at('referencePoints','candidatePoints')
    check(winner >= 31 && loser < 31, 'terminal scores')
    check(m['nextDealer'] == %w[south east north west][(m['rotation'] + m['deals']) % 4], 'dealer progression')
  end
  wins = records.count { |m| m['candidateWon'] }
  check(r.values_at('candidateWins','referenceWins','unresolved') == [wins,2048-wins,0], 'winner counts')
  stream_wins = groups.map { |_, ms| ms.count { |m| m['candidateWon'] } / 8.0 }
  margins = groups.map { |_, ms| ms.sum { |m| m['candidatePoints'] - m['referencePoints'] } / 8.0 }
  check(r['streamWinLower'] == stream_wins && r['streamWinUpper'] == stream_wins, 'win arrays')
  check(r['streamScoreMargins'] == margins, 'margin arrays')
  win_interval = interval(stream_wins,2.39397979981851)
  margin_interval = interval(margins,1.96)
  {'adjustedWinLowerInterval'=>win_interval,'adjustedWinUpperInterval'=>win_interval,'scoreMarginInterval95'=>margin_interval}.each do |key, calculated|
    calculated.each { |field, value| check((r[key][field] - value).abs < 1e-10, "#{key}.#{field}") }
  end
  hands = records.sum { |m| m['playedHands'] }
  c, ref = r.values_at('candidateMetrics','referenceMetrics')
  check(c['contracts'] + ref['contracts'] == hands, 'contract count')
  check(c['defenses'] == ref['contracts'] && ref['defenses'] == c['contracts'], 'defenses')
  check(c['made'] + ref['defeated'] == c['contracts'] && ref['made'] + c['defeated'] == ref['contracts'], 'made/defeated')
  [c,ref].each do |m|
    check(m['cards']['decisions'] == 26 * hands, 'card count')
    %w[bidding cards].each do |kind|
      t = m[kind]
      check(t['fallbacks'].between?(0,t['decisions']), 'fallback count')
      check(t['medianMS'] >= 0 && t['medianMS'] <= t['p95MS'] && t['p95MS'] <= t['maxMS'], 'timing order')
    end
  end
  {
    reference: r['reference'], fileSHA256: Digest::SHA256.file(path).hexdigest,
    matches: records.length, candidateWins: wins, winInterval: win_interval,
    scoreMarginInterval95: margin_interval, passesIndividualGate: win_interval['lower'] > 0.5,
    playedHands: hands, allPass: records.sum { |m| m['allPass'] },
    maxDeals: records.map { |m| m['deals'] }.max,
    cardDecisions: 52 * hands, biddingDecisions: c['bidding']['decisions'] + ref['bidding']['decisions'],
    fallbacks: [c,ref].sum { |m| m['bidding']['fallbacks'] + m['cards']['fallbacks'] },
    validation: 'metadata, limits, balanced records, scores, dealer progression, counts, contract accounting, primary and secondary intervals passed'
  }
end
puts JSON.pretty_generate(reports)
