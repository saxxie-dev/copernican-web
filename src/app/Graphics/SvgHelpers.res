open! Coordinates
open! Belt.Float

let toCartesianPoint = (d: cartesianCoord) => {
  `${toString(d.x)} ${toString(d.y)}`
}

let toPolarPoint = (p: polarCoord) => {
  let d = polarToCartesian(p)
  `${toString(d.x)} ${toString(d.y)}`
}
