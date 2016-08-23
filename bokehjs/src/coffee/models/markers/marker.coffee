_ = require "underscore"

Glyph = require "../glyphs/glyph"
hittest = require "../../common/hittest"
p = require "../../core/properties"

class MarkerView extends Glyph.View

  draw_legend: (ctx, x0, x1, y0, y1) ->
    reference_point = @get_reference_point() ? 0

    # using objects like this seems a little wonky, since the keys are coerced to
    # stings, but it works
    indices = [reference_point]
    sx = { }
    sx[reference_point] = (x0+x1)/2
    sy = { }
    sy[reference_point] = (y0+y1)/2
    size = { }
    size[reference_point] = Math.min(Math.abs(x1-x0), Math.abs(y1-y0))*0.4
    angle = { }
    angle[reference_point] = 0

    data = {sx:sx, sy:sy, _size: size, _angle: angle}
    @_render(ctx, indices, data)

  _render: (ctx, indices, {sx, sy, _size, _angle}) ->
    for i in indices
      if isNaN(sx[i]+sy[i]+_size[i]+_angle[i])
        continue

      r = _size[i]/2

      ctx.beginPath()
      ctx.translate(sx[i], sy[i])

      if _angle[i]
        ctx.rotate(_angle[i])

      @_render_one(ctx, i, sx[i], sy[i], r, @visuals.line, @visuals.fill)

      if _angle[i]
        ctx.rotate(-_angle[i])

      ctx.translate(-sx[i], -sy[i])

  _index_data: () ->
    @_xy_index()

  _mask_data: (all_indices) ->
    # dilate the inner screen region by max_size and map back to data space for use in
    # spatial query
    hr = @renderer.plot_view.frame.get('h_range')
    vx0 = hr.get('start') - @max_size
    vx1 = hr.get('end') + @max_size
    [x0, x1] = @renderer.xmapper.v_map_from_target([vx0, vx1], true)

    vr = @renderer.plot_view.frame.get('v_range')
    vy0 = vr.get('start') - @max_size
    vy1 = vr.get('end') + @max_size
    [y0, y1] = @renderer.ymapper.v_map_from_target([vy0, vy1], true)

    bbox = hittest.validate_bbox_coords([x0, x1], [y0, y1])
    return (x.i for x in @index.search(bbox))

  _hit_point: (geometry) ->
    [vx, vy] = [geometry.vx, geometry.vy]
    sx = @renderer.plot_view.canvas.vx_to_sx(vx)
    sy = @renderer.plot_view.canvas.vy_to_sy(vy)

    vx0 = vx - @max_size
    vx1 = vx + @max_size
    [x0, x1] = @renderer.xmapper.v_map_from_target([vx0, vx1], true)

    vy0 = vy - @max_size
    vy1 = vy + @max_size
    [y0, y1] = @renderer.ymapper.v_map_from_target([vy0, vy1], true)

    bbox = hittest.validate_bbox_coords([x0, x1], [y0, y1])
    candidates = (x.i for x in @index.search(bbox))

    hits = []
    for i in candidates
      s2 = @_size[i]/2
      dist = Math.abs(@sx[i]-sx) + Math.abs(@sy[i]-sy)
      if Math.abs(@sx[i]-sx) <= s2 and Math.abs(@sy[i]-sy) <= s2
        hits.push([i, dist])
    result = hittest.create_hit_test_result()
    result['1d'].indices = _.chain(hits)
      .sortBy((elt) -> return elt[1])
      .map((elt) -> return elt[0])
      .value()
    return result

  _hit_rect: (geometry) ->
    [x0, x1] = @renderer.xmapper.v_map_from_target([geometry.vx0, geometry.vx1], true)
    [y0, y1] = @renderer.ymapper.v_map_from_target([geometry.vy0, geometry.vy1], true)
    bbox = hittest.validate_bbox_coords([x0, x1], [y0, y1])
    result = hittest.create_hit_test_result()
    result['1d'].indices = (x.i for x in @index.search(bbox))
    return result

  _hit_poly: (geometry) ->
    [vx, vy] = [geometry.vx, geometry.vy]
    sx = @renderer.plot_view.canvas.v_vx_to_sx(vx)
    sy = @renderer.plot_view.canvas.v_vy_to_sy(vy)

    # TODO (bev) use spatial index to pare candidate list
    candidates = [0...@sx.length]

    hits = []
    for i in [0...candidates.length]
      idx = candidates[i]
      if hittest.point_in_poly(@sx[i], @sy[i], sx, sy)
        hits.push(idx)
    result = hittest.create_hit_test_result()
    result['1d'].indices = hits
    return result

class Marker extends Glyph.Model

  @coords [ ['x', 'y'] ]
  @mixins ['line', 'fill']
  @define {
    size:  [ p.DistanceSpec, { units: "screen", value: 4 } ]
    angle: [ p.AngleSpec,    0                             ]
  }

gen = (type, f) ->
  class V extends MarkerView
    _render_one: f

  class M extends Marker
    default_view: V
    type: type

  return {
    Model: M
    View: V
  }

module.exports =
  gen: gen
  Model: Marker
  View: MarkerView
