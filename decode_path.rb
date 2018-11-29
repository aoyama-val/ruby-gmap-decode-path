def decode_path(encoded_path)
  len = encoded_path.length
  path = []
  index = 0
  lat = 0
  lng = 0
  while index < len
    result = 1
    shift = 0
    loop do
      b = encoded_path[index].ord - 63 - 1
      index += 1
      result += b << shift
      shift += 5
      break unless b >= 0x1f
    end
    lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1)

    result = 1
    shift = 0
    loop do
      b = encoded_path[index].ord - 63 - 1
      index += 1
      result += b << shift
      shift += 5
      break unless b >= 0x1f
    end
    lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

    path.push({ lat: lat * 1e-5, lng: lng * 1e-5 })
  end

  return path
end

path = 'uan~FdhjvOvk@i{M}qDwpB'
p decode_path(path)
