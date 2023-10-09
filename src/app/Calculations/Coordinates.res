// Utilites for coordinate systems

open! Js.Math
open! Belt.Float

type date = Js.Date.t

type polarCoord = {
  r: float,
  theta: float,
}

type cartesianCoord = {
  x: float,
  y: float,
}

type cartesianCoord3d = {
  x: float,
  y: float,
  z: float,
}

let cartesian3dToCartesian = ({x, y}: cartesianCoord3d): cartesianCoord => {
  {x, y}
}

let euclideanNorm2 = ((x, y): (float, float)): float => {
  sqrt(pow_float(~base=x, ~exp=2.0) + pow_float(~base=y, ~exp=2.0))
}

let cartesianToPolar = ({x, y}: cartesianCoord): polarCoord => {
  {
    r: euclideanNorm2((x, y)),
    theta: atan2(~y, ~x, ()),
  }
}

let polarToCartesian = ({r, theta}): cartesianCoord => {
  {
    x: r * cos(theta),
    y: r * sin(theta),
  }
}

let addDisplacementCartesian = (p1: cartesianCoord, p2: cartesianCoord): cartesianCoord => {
  {
    x: p1.x + p2.x,
    y: p1.y + p2.y,
  }
}

let addDisplacementPolar = (p1: polarCoord, p2: polarCoord): polarCoord => {
  cartesianToPolar(addDisplacementCartesian(polarToCartesian(p1), polarToCartesian(p2)))
}

let translateCenterCartesian = (
  point: cartesianCoord,
  reference: cartesianCoord,
): cartesianCoord => {
  {
    x: point.x - reference.x,
    y: point.y - reference.y,
  }
}

let translateCenterPolar = (point: polarCoord, reference: polarCoord): polarCoord => {
  cartesianToPolar(translateCenterCartesian(polarToCartesian(point), polarToCartesian(reference)))
}

let scaleCartesian = (c: float, {x, y}: cartesianCoord): cartesianCoord => {
  {
    x: c * x,
    y: c * y,
  }
}

let scalePolar = (c: float, {r, theta}): polarCoord => {
  {
    r: c * r,
    theta,
  }
}

let rotatePolar = (delta: float, {r, theta}): polarCoord => {
  {
    r,
    theta: theta + delta,
  }
}

let rotateCartesian = (theta: float, p: cartesianCoord) => {
  polarToCartesian(rotatePolar(theta, cartesianToPolar(p)))
}

let degrees = (x: float): float => {
  x / 180. * _PI
}

let astroEpoch = Js.Date.utcWithYMDH(~year=2000., ~month=0., ~date=0., ~hours=12., ())
let dateToAstroSecs = (date: date): float => {
  (date->Js.Date.getTime - astroEpoch) / 1000.
}
let astroSecsToDate = (t: float): date => {
  Js.Date.fromFloat(astroEpoch + 1000. * t)
}
