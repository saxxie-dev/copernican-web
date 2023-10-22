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
  let make = (~radius: float, ~theta: float, ~id: string) => {
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

module Background = {
  @react.component
  let make = () => {
    <>
      <radialGradient id="bg-sunlight" cx={pct(50.)} cy={pct(50.)} r={pct(44.)}>
        <stop offset={pct(0.)} stopColor="#229" />
        <stop offset={pct(100.)} stopColor="#000" />
      </radialGradient>
      <circle r={pct(50.)} cx={dp(0.)} cy={dp(0.)} fill="url(#bg-sunlight)" />
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
      <Background />
      <Zodiac.Zodiac
        theta0={0.}
        conformalCenter={{r: 45.0, theta: -.earthAngle.theta}}
        signs={LatinZodiacData.zodiacSigns}
      />
      <Earth radius={45.0} theta={earthAngle.theta} id="earth" />
      {React.array(planetSvgs)}
      <Planet radius={0.} theta={0.} id="sol" />
    </svg>
  }
}
