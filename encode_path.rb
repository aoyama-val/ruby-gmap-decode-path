require "benchmark"

def encode_value(_value, method: 1)
  case method
  when 1
    return encode_value1(_value)
  when 2
    return encode_value2(_value)
  end
end

# 2進数の文字列として扱う方法
# slower
def encode_value1(_value)
  # 2. Take the decimal value and multiply it by 1e5, rounding the result:
  value = (_value * 1e5).round
  # 3. Convert the decimal value to binary. Note that a negative value must be calculated using its two's complement by inverting the binary value and adding one to the result:
  if value < 0
    value = 2**32 + value
  end
  binary = "%032d" % value.to_s(2)
  # 4. Left-shift the binary value one bit:
  binary = binary[1..-1] + "0"
  # 5. If the original decimal value is negative, invert this encoding:
  binary = binary.chars
  if _value < 0
    binary = binary.map {|x| x == "0" ? "1" : "0"}
  end
  # 6. Break the binary value out into 5-bit chunks (starting from the right hand side):
  # 7. Place the 5-bit chunks into reverse order:
  five_bit_chunks = binary.reverse.each_slice(5).to_a.map {|x| x.reverse.join}
  while five_bit_chunks[-1] =~ /^\A0+\z/
    five_bit_chunks.pop
  end
  # 8. OR each value with 0x20 if another bit chunk follows:
  five_bit_chunks = five_bit_chunks.map.with_index {|five_bit_chunk, i| (i == five_bit_chunks.length - 1 ? "0" : "1") + five_bit_chunk }
  # 9. Convert each value to decimal:
  five_bit_chunks = five_bit_chunks.map {|x| x.to_i(2) }
  # 10. Add 63 to each value:
  five_bit_chunks = five_bit_chunks.map {|x| x + 63 }
  return five_bit_chunks.map {|x| x.chr }.join
end

# Integerのまま計算する方法
# faster
def encode_value2(_value)
  # 2. Take the decimal value and multiply it by 1e5, rounding the result:
  value = (_value * 1e5).round
  # 3. Convert the decimal value to binary. Note that a negative value must be calculated using its two's complement by inverting the binary value and adding one to the result:
  if value < 0
    value = 2**32 + value
  end
  # 4. Left-shift the binary value one bit:
  value = value << 1
  # 5. If the original decimal value is negative, invert this encoding:
  if _value < 0
    value = ~value
  end
  # 6. Break the binary value out into 5-bit chunks (starting from the right hand side):
  five_bit_chunks = [
    (value & 0b11000000000000000000000000000000) >> 30,
    (value & 0b00111110000000000000000000000000) >> 25,
    (value & 0b00000001111100000000000000000000) >> 20,
    (value & 0b00000000000011111000000000000000) >> 15,
    (value & 0b00000000000000000111110000000000) >> 10,
    (value & 0b00000000000000000000001111100000) >> 5,
    (value & 0b00000000000000000000000000011111) >> 0,
  ]
  while five_bit_chunks[0] == 0 && five_bit_chunks.length > 1   # 配列の長さが0にならないように
    five_bit_chunks.shift
  end
  # 7. Place the 5-bit chunks into reverse order:
  five_bit_chunks.reverse!
  # 8. OR each value with 0x20 if another bit chunk follows:
  five_bit_chunks = five_bit_chunks.map.with_index {|five_bit_chunk, i| (i == five_bit_chunks.length - 1 ? five_bit_chunk : five_bit_chunk | 0x20)}
  # 9. Convert each value to decimal:
  # 10. Add 63 to each value:
  decimals = five_bit_chunks.map {|x| x + 63 }
  return decimals.map {|x| x.chr }.join
end

def encode_path(latlngs, method: 2)
  result = ""
  lat = 0
  lng = 0
  latlngs.each do |latlng|
    lat_delta = latlng[:lat] - lat
    lng_delta = latlng[:lng] - lng
    result += encode_value(lat_delta, method: method) + encode_value(lng_delta, method: method)
    lat = latlng[:lat]
    lng = latlng[:lng]
  end
  return result
end

if $0 == __FILE__
  #p encode_value(-179.9832104)
  #p encode_value(38.5)
  #p encode_value(-120.2)
  #p encode_value(40.7 - 38.5)
  #p encode_value(-120.95 - (-120.2))
  #p encode_value(43.252 - 40.7)
  #p encode_value(-126.453 - (-120.95))

  p encode_path([
    { lat: 38.5, lng: -120.2 },
    { lat: 40.7, lng: -120.95 },
    { lat: 43.252, lng: -126.453 },
  ])
end


# encode_value1とencode_value2をベンチマーク
#label_width = 10
#times = 10000
#Benchmark.bm label_width do |r|
#  r.report "encode_value1" do
#    times.times do
#      encode_value1(-179.9832104)
#    end
#  end
#  r.report "encode_value2" do
#    times.times do
#      encode_value2(-179.9832104)
#    end
#  end
#end
