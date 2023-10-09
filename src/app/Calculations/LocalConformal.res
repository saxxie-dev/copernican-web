// Arbitrarily going to call a transformation "locally conformal" if it preserves angles at one point.
// Handles positions given in polar coordinates, and outputs new radii such that all angles relative to a "fixed point" (earth) remain constant
open! Coordinates
open! Js.Math
open! Belt.Float

let locallyConformalMap = (
  fixedPoint: polarCoord,
  newFixedPoint: polarCoord,
  point: polarCoord,
  newRadius: float,
): polarCoord => {
  let polarDisplacement = translateCenterPolar(point, fixedPoint)
  let alignment =
    cos(fixedPoint.theta) * cos(polarDisplacement.theta) +
      sin(fixedPoint.theta) * sin(polarDisplacement.theta)
  let weightedAlign = -2.0 * newFixedPoint.r * alignment

  let intersectionOffset =
    fixedPoint.r * cos(fixedPoint.theta - polarDisplacement.theta) - polarDisplacement.r

  let newDistance =
    0.5 *
    (weightedAlign -
    sign_float(intersectionOffset) *
    sqrt(
      weightedAlign * weightedAlign +
        4.0 * (newRadius * newRadius - newFixedPoint.r * newFixedPoint.r),
    ))
  addDisplacementPolar(
    newFixedPoint,
    rotatePolar(
      newFixedPoint.theta - fixedPoint.theta,
      scalePolar(newDistance / polarDisplacement.r, polarDisplacement),
    ),
  )
}
