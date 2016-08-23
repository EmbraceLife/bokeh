M = require "./marker"

SQ3 = Math.sqrt(3)

_one_x =  (ctx, r) ->
  ctx.moveTo(-r,  r)
  ctx.lineTo( r, -r)
  ctx.moveTo(-r, -r)
  ctx.lineTo( r,  r)

_one_cross = (ctx, r) ->
  ctx.moveTo( 0,  r)
  ctx.lineTo( 0, -r)
  ctx.moveTo(-r,  0)
  ctx.lineTo( r,  0)

_one_tri = (ctx, r) ->
  h = r * SQ3
  a = h/3

  # TODO (bev) use viewstate to take y-axis inversion into account
  ctx.moveTo(-r, a)
  ctx.lineTo(r, a)
  ctx.lineTo(0, a-h)
  ctx.closePath()

_asterisk = (ctx, i, sx, sy, r, vl, vf) ->
  r2 = r*0.65

  _one_cross(ctx, r)
  _one_x(ctx, r2)

  if vl.doit
    vl.set_vectorize(ctx, i)
    ctx.stroke()

  return

_circle_cross = (ctx, i, sx, sy, r, vl, vf)  ->
  ctx.arc(0, 0, r, 0, 2*Math.PI, false)

  if vf.doit
    vf.set_vectorize(ctx, i)
    ctx.fill()

  if vl.doit
    vl.set_vectorize(ctx, i)
    _one_cross(ctx, r)
    ctx.stroke()

  return

_circle_x = (ctx, i, sx, sy, r, vl, vf) ->
  ctx.arc(0, 0, r, 0, 2*Math.PI, false)

  if vf.doit
    vf.set_vectorize(ctx, i)
    ctx.fill()

  if vl.doit
    vl.set_vectorize(ctx, i)
    _one_x(ctx, r)
    ctx.stroke()

  return

_cross = (ctx, i, sx, sy, r, vl, vf) ->
  _one_cross(ctx, r)

  if vl.doit
    vl.set_vectorize(ctx, i)
    ctx.stroke()

  return

_diamond = (ctx, i, sx, sy, r, vl, vf) ->
  ctx.moveTo(0, r)
  ctx.lineTo(r/1.5, 0)
  ctx.lineTo(0, -r)
  ctx.lineTo(-r/1.5, 0)
  ctx.closePath()

  if vf.doit
    vf.set_vectorize(ctx, i)
    ctx.fill()

  if vl.doit
    vl.set_vectorize(ctx, i)
    ctx.stroke()

  return

_diamond_cross = (ctx, i, sx, sy, r, vl, vf) ->
  ctx.moveTo(0, r)
  ctx.lineTo(r/1.5, 0)
  ctx.lineTo(0, -r)
  ctx.lineTo(-r/1.5, 0)
  ctx.closePath()

  if vf.doit
    vf.set_vectorize(ctx, i)
    ctx.fill()

  if vl.doit
    vl.set_vectorize(ctx, i)
    _one_cross(ctx, r)
    ctx.stroke()

  return

_inverted_triangle = (ctx, i, sx, sy, r, vl, vf) ->
  ctx.rotate(Math.PI)
  _one_tri(ctx, r)
  ctx.rotate(-Math.PI)

  if vf.doit
    vf.set_vectorize(ctx, i)
    ctx.fill()

  if vl.doit
    vl.set_vectorize(ctx, i)
    ctx.stroke()

  return

_square = (ctx, i, sx, sy, r, vl, vf) ->
  size = 2*r
  ctx.rect(-r, -r, size, size)

  if vf.doit
    vf.set_vectorize(ctx, i)
    ctx.fill()

  if vl.doit
    vl.set_vectorize(ctx, i)
    ctx.stroke()

  return

_square_cross = (ctx, i, sx, sy, r, vl, vf) ->
  size = 2*r
  ctx.rect(-r, -r, size, size)

  if vf.doit
    vf.set_vectorize(ctx, i)
    ctx.fill()

  if vl.doit
    vl.set_vectorize(ctx, i)
    _one_cross(ctx, r)
    ctx.stroke()

  return

_square_x = (ctx, i, sx, sy, r, vl, vf) ->
  size = 2*r
  ctx.rect(-r, -r, size, size)

  if vf.doit
    vf.set_vectorize(ctx, i)
    ctx.fill()

  if vl.doit
    vl.set_vectorize(ctx, i)
    _one_x(ctx, r)
    ctx.stroke()

  return

_triangle = (ctx, i, sx, sy, r, vl, vf) ->
  _one_tri(ctx, r)

  if vf.doit
    vf.set_vectorize(ctx, i)
    ctx.fill()

  if vl.doit
    vl.set_vectorize(ctx, i)
    ctx.stroke()

  return

_x = (ctx, i, sx, sy, r, vl, vf) ->
  _one_x(ctx, r)

  if vl.doit
    vl.set_vectorize(ctx, i)
    ctx.stroke()

  return

module.exports =
  Asterisk:         M.gen('Asterisk', _asterisk)
  CircleCross:      M.gen('CircleCross', _circle_cross)
  CircleX:          M.gen('CircleX', _circle_x)
  Cross:            M.gen('Cross', _cross)
  Diamond:          M.gen('Diamond', _diamond)
  DiamondCross:     M.gen('DiamondCross', _diamond_cross)
  InvertedTriangle: M.gen('InvertedTriangle', _inverted_triangle)
  Square:           M.gen('Square', _square)
  SquareCross:      M.gen('SquareCross', _square_cross)
  SquareX:          M.gen('SquareX', _square_x)
  Triangle:         M.gen('Triangle', _triangle)
  X:                M.gen('X', _x)
