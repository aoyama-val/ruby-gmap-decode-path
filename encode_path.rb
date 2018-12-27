def encode_value(_value)
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

def encode_path(latlngs)
  result = ""
  lat = 0
  lng = 0
  latlngs.each do |latlng|
    lat_delta = latlng[:lat] - lat
    lng_delta = latlng[:lng] - lng
    result += encode_value(lat_delta) + encode_value(lng_delta)
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
