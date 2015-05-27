function d = lldistmat(lats, lons)

Lats = repmat(lats, [1 size(lats,1)]);
Lons = repmat(lons, [1 size(lats,1)]);
jnk1 = [Lats(:) Lons(:)];
Lats = Lats';
Lons = Lons';
jnk2 = [Lats(:) Lons(:)];
d = distance(jnk1, jnk2, referenceSphere('earth', 'km'));
d = reshape(d, size(Lats));