require 'json'
require 'time'

$drinks_hash = JSON.parse(File.read("drinks.json"))
$drinks = 0
$start_time = Time.now

def load_data
    k = $drinks_hash.keys.last
    time = (Time.now - Time.parse(k))/3600
    if $drinks_hash[k]["drinks"] - time > 0
        $drinks = $drinks_hash[k]["drinks"] - time
        $start_time = Time.parse(k)
    end
end

def save_data
    $drinks_hash[Time.now] = {"drinks" => $drinks.round(2), "promille" => calculatePromille()}
    File.open("drinks.json", "w"){|f| f.write(JSON.dump($drinks_hash))}
end

def calculateHoursSinceStart()
    return (Time.now - $start_time)/3600
end

def calculateUnits()
    units = ($drinks - calculateHoursSinceStart()).round(2)
    return [0, units].max
end

def calculatePromille()
    pm = ((12*$drinks) / (130*0.7) - (0.15*calculateHoursSinceStart())).round(2)
    return [pm,0].max
end

def parse_add(x)
    if match = x.scan(/\d+\.?\d*/)
        if match.empty?
            $drinks += 1
        else
            $drinks += match.first.to_f
        end
    end

    save_data
end

def show_log(x)
    pp $drinks_hash
end

def reset
    $drinks = 0
    $start_time = Time.now
end

load_data

loop do
    x = gets
    parse_add(x) if x =~ /^add/ 
    show_log(x) if x =~ /^log$/ 
    reset if x =~ /^reset$/
       
    puts("You have drunk #{$drinks.round(4)} drinks and you have #{calculateUnits()} units in your system (#{calculatePromille()}‰)")
end

END { save_data }