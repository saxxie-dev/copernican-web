let pct = (s: float): string => {
  `${s->Belt.Float.toString}%`
}

let dp = Belt.Float.toString

module Planet = {
  @react.component
  let make = (~radius: float, ~theta: float, ~id: string) => {
    Js.Console.log3(radius, theta, id)
    let (pressed, setPressed) = React.useState(_ => false)
    <>
      {if radius > 0. {
        <radialGradient
          id cx={pct(50. *. (1. +. cos(theta)))} cy={pct(50. *. (1. -. sin(theta)))} r={pct(44.)}>
          <stop offset={pct(0.)} stopColor="#FFF" />
          <stop offset={pct(100.)} stopColor="#FFF" stopOpacity="0.05" />
        </radialGradient>
      } else {
        <> </>
      }}
      <circle
        cx={dp(0.)}
        cy={dp(0.)}
        r={dp(radius)}
        stroke={`url(#${id})`}
        strokeWidth={dp(1.)}
        strokeDasharray={"5 5"}
        fill="#FFF"
        fillOpacity={pressed ? "0.03" : "0"}
      />
      <circle
        cx={dp(radius *. cos(theta))}
        cy={dp(-.radius *. sin(theta))}
        r={dp(5.0)}
        fill="#FFF"
        onMouseDown={_ => setPressed(_ => true)}
        onMouseUp={_ => setPressed(_ => false)}
      />
    </>
  }
}

module Earth = {
  open! Js.Math
  open! React
  @react.component
  let make = (~radius: float, ~theta: float, ~id: string, ~angles: array<float>) => {
    let (pressed, setPressed) = React.useState(_ => false)
    <>
      {if radius > 0. {
        <radialGradient
          id cx={pct(50. *. (1. +. cos(theta)))} cy={pct(50. *. (1. -. sin(theta)))} r={pct(44.)}>
          <stop offset={pct(0.)} stopColor="#FFF" />
          <stop offset={pct(100.)} stopColor="#FFF" stopOpacity="0.05" />
        </radialGradient>
      } else {
        <> </>
      }}
      <circle
        cx={dp(0.)}
        cy={dp(0.)}
        r={dp(radius)}
        stroke={`url(#${id})`}
        strokeWidth={dp(1.)}
        strokeDasharray={"5 5"}
        fill="#FFF"
        fillOpacity={pressed ? "0.03" : "0"}
      />
      <circle
        cx={dp(0.)}
        cy={dp(0.)}
        r={dp(130.)}
        stroke={"white"}
        strokeWidth={dp(1.)}
        strokeDasharray="5 5"
        fill="#FFF"
        fillOpacity={pressed ? "0.03" : "0"}
      />
      <circle
        cx={dp(radius *. cos(theta))}
        cy={dp(-.radius *. sin(theta))}
        r={dp(5.0)}
        fill="#FFF"
        onMouseDown={_ => setPressed(_ => true)}
        onMouseUp={_ => setPressed(_ => false)}
      />
      <radialGradient id="Zodiac">
        <stop offset={pct(0.)} stopColor="red" />
        <stop offset={pct(50.)} stopColor="blue" />
        <stop offset={pct(100.)} stopColor="green" />
      </radialGradient>
      {React.array(
        Belt.Array.mapWithIndex(angles, (i, theta2) => {
          open! Belt.Float
          let ix = radius * cos(theta)
          let iy = -.radius * sin(theta)
          let b = 2. * (ix * cos(theta2) + iy * sin(theta2))
          let vt = 0.5 * (-.b + sqrt(b * b - 4. * (radius * radius - 130. * 130.)))
          let theta3 = theta2 + _PI / 6.
          let b2 = 2. * (ix * cos(theta3) + iy * sin(theta3))
          let vt2 = 0.5 * (-.b2 + sqrt(b2 * b2 - 4. * (radius * radius - 130. * 130.)))

          <path
            key={toString(theta2)}
            d={`M${toString(ix)} ${toString(iy)}
                l${toString(vt * cos(theta2))} ${toString(vt * sin(theta2))}
                A130 130 0 0 1 ${toString(ix + vt2 * cos(theta3))} ${toString(
                iy + vt2 * sin(theta3),
              )}
              `}
            fill="url(#Zodiac)"
            fillOpacity={mod(i, 2) == 0 ? "0.4" : "0"}
          />
        }),
      )}
    </>
  }
}

module SolarSystem = {
  @react.component
  let make = (~time: Js.Date.t) => {
    let earthAngle = KeplerOrbit.projectedPositionPolar(PlanetData.PlanetMotions.earth, time)

    let planetsToRender = [#pluto, #uranus, #neptune, #saturn, #jupiter, #mars, #venus, #mercury]
    let planetSvgs = Array.mapi((i, planet) => {
      open! KeplerOrbit
      let motion = PlanetData.planetMotion(planet)
      let trueProjectedPosition = projectedPositionPolar(motion, time)
      let renderedPosition = LocalConformal.locallyConformalMap(
        earthAngle,
        {r: 45.0, theta: earthAngle.theta},
        trueProjectedPosition,
        Belt.Int.toFloat(100 - 10 * i),
      )
      <Planet
        radius={renderedPosition.r}
        theta={renderedPosition.theta}
        key={(planet :> string)}
        id={(planet :> string)}
      />
    }, planetsToRender)

    <svg className="m-auto" height={pct(100.)} viewBox={"-130 -130 260 260"}>
      <Earth
        radius={45.0}
        theta={earthAngle.theta}
        id="earth"
        angles={Array.map(
          x => x *. Js.Math._PI /. 6.,
          [0., 1., 2., 3., 4., 5., 6., 7., 8., 9., 10., 11., 12.],
        )}
      />
      {React.array(planetSvgs)}
      <Planet radius={0.} theta={0.} id="sol" />
    </svg>
  }
}
