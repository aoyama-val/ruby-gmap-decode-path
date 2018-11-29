# Google MapsのpathをデコードするRuby実装

- https://developers.google.com/maps/documentation/utilities/polylinealgorithm
- https://github.com/googlemaps/android-maps-utils/blob/bbe0f3466bc2f716a73bd9583d47c390dd7f0f4a/library/src/com/google/maps/android/PolyUtil.java#L490

```
path = 'uan~FdhjvOvk@i{M}qDwpB'
p decode_path(path)

# => [{:lat=>41.85643, :lng=>-87.71219}, {:lat=>41.849270000000004, :lng=>-87.63598}, {:lat=>41.877900000000004, :lng=>-87.61778000000001}]
```
