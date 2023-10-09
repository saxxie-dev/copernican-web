// Lib for calculating orbits according to kepler's equations
// Does not handle moons (yet)

open! Js.Math
open! Belt.Float
open! Coordinates

// Extended variant of orbitSpec - any invariants characterizing the orbit regardless of minimality
type orbitConsts = {
  // Shape of 2d ellipse
  semiMajor: float,
  semiMinor: float,
  eccentricRadius: float,
  eccentricity: float,
  // Orientation in 3-space
  inclination: float,
  ascendingNodeLongitude: float,
  periapsisAngle: float,
  // Motion in time
  epochAngle: float,
  referencePeriapsisTime: date,
  orbitPeriod: float,
  meanMotion: float,
  sweepRate: float,
}

module OrbitSpec = {
  type orbitSpec = {
    // Ellipse shape
    semiMajor: float,
    eccentricity: float,
    // Elliptic plane + orientation
    inclination: float, // 0..PI/2
    ascendingNodeLongitude: float, // -PI..PI
    periapsisAngle: float, // 0..2*PI
    // Orbit initial angle
    epochAngle: float,
  }

  let _GM = 1.98847e30 * 6.6743015e-11 / 3.347927e+33

  let orbitPeriod = (orbit: orbitSpec): float => {
    let {semiMajor} = orbit
    2.0 * _PI * sqrt(pow_float(~base=semiMajor, ~exp=3.) / _GM)
  }

  let meanMotion = (orbit: orbitSpec): float => {
    2.0 * _PI / orbitPeriod(orbit)
  }

  let sweepRate = (orbit: orbitSpec): float => {
    let {eccentricity, semiMajor} = orbit
    sqrt(1. - eccentricity * eccentricity) * meanMotion(orbit) * semiMajor * semiMajor
  }

  let perihelionTime = (orbit: orbitSpec): date => {
    let {epochAngle, periapsisAngle, ascendingNodeLongitude} = orbit
    astroSecsToDate(
      (periapsisAngle + ascendingNodeLongitude - epochAngle) / (2. * _PI) * orbitPeriod(orbit),
    )
  }
  let aphelionTime = (orbit: orbitSpec): date => {
    let {epochAngle, periapsisAngle, ascendingNodeLongitude} = orbit
    astroSecsToDate(
      ((periapsisAngle + ascendingNodeLongitude - epochAngle) / (2. * _PI) + 0.5) *
        orbitPeriod(orbit),
    )
  }

  let radiusAtTrueAnomaly = (orbit: orbitSpec, trueAnomaly: float): float => {
    let {semiMajor, eccentricity} = orbit
    semiMajor * (1. - eccentricity * eccentricity) / (1. + eccentricity * cos(trueAnomaly))
  }
  let radiusAtPerihelion = (orbit: orbitSpec) => radiusAtTrueAnomaly(orbit, 0.)
  let radiusAtAphelion = (orbit: orbitSpec) => radiusAtTrueAnomaly(orbit, _PI)

  let eccentricRadius = (orbit: orbitSpec) => {
    radiusAtPerihelion(orbit) / (1. - orbit.eccentricity)
  }

  let toConsts = (spec: orbitSpec): orbitConsts => {
    let {
      semiMajor,
      eccentricity,
      inclination,
      ascendingNodeLongitude,
      periapsisAngle,
      epochAngle,
    } = spec
    {
      // Shape of 2d ellipse
      semiMajor,
      semiMinor: eccentricity * semiMajor,
      eccentricRadius: eccentricRadius(spec),
      eccentricity,
      // Orientation in 3-space
      inclination,
      ascendingNodeLongitude,
      periapsisAngle,
      // Motion in time
      epochAngle,
      referencePeriapsisTime: perihelionTime(spec),
      orbitPeriod: orbitPeriod(spec),
      meanMotion: meanMotion(spec),
      sweepRate: sweepRate(spec),
    }
  }
}

// Tries converging to an attractive fixed point.
// Do not run on diverging function, obviously
let rec approximateFixedPoint = (f: float => float, x: float): float => {
  let y = f(x)
  if y - x < 1e-8 {
    y
  } else {
    approximateFixedPoint(f, y)
  }
}

let meanAnomaly = (orbit: orbitConsts, time: date) => {
  orbit.meanMotion * (time->dateToAstroSecs - orbit.referencePeriapsisTime->dateToAstroSecs)
}

let eccentricAnomaly = (orbit: orbitConsts, time: date): float => {
  let {eccentricity} = orbit
  let _M = meanAnomaly(orbit, time)
  approximateFixedPoint(_E => _M + eccentricity * sin(_E), 0.)
}

let trueRadius = (orbit: orbitConsts, time: date) => {
  orbit.eccentricRadius * (1. - orbit.eccentricity * cos(eccentricAnomaly(orbit, time)))
}

let trueAngle = (orbit: orbitConsts, time: date) => {
  let {eccentricity} = orbit
  2. *
  atan(tan(eccentricAnomaly(orbit, time) / 2.) * sqrt((1. + eccentricity) / (1. - eccentricity)))
}

let truePosition = (orbit: orbitConsts, time: date): (float, float, float) => {
  let r = trueRadius(orbit, time)
  let theta = trueAngle(orbit, time)
  let {inclination, ascendingNodeLongitude, periapsisAngle} = orbit
  let omega_ = ascendingNodeLongitude + periapsisAngle
  (r * cos(theta + omega_), r * sin(theta + omega_), r * sin(periapsisAngle + theta) * inclination)
}

let projectedPositionPolar = (orbit: orbitConsts, time: date): polarCoord => {
  let (x, y, _) = truePosition(orbit, time)
  cartesianToPolar({x, y})
}

let projectedAngle = (orbit: orbitConsts, time: date): float => {
  let {theta} = projectedPositionPolar(orbit, time)
  theta
}
