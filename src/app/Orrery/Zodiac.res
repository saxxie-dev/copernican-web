open! Js.Math
open! Belt.Float

let pct = (s: float): string => {
  `${s->Belt.Float.toString}%`
}

let dp = Belt.Float.toString

let _INNER_RADIUS = 112.
let _OUTER_RADIUS = 127.
let _TEXT_RADIUS = 0.8 * _INNER_RADIUS + 0.2 * _OUTER_RADIUS

module SignWedge = {
  @react.component
  let make = (~center: Coordinates.polarCoord, ~theta2: float) => {
    open! Belt.Float

    let {r: radius, theta} = center
    let ix = radius * cos(theta)
    let iy = radius * sin(theta)
    let b = 2. * (ix * cos(theta2) + iy * sin(theta2))
    let vt = 0.5 * (-.b + sqrt(b * b - 4. * (radius * radius - _INNER_RADIUS * _INNER_RADIUS)))
    let theta3 = theta2 + _PI / 6.
    let b2 = 2. * (ix * cos(theta3) + iy * sin(theta3))
    let vt2 = 0.5 * (-.b2 + sqrt(b2 * b2 - 4. * (radius * radius - _INNER_RADIUS * _INNER_RADIUS)))

    <>
      <path
        d={`
        M${toString(ix)}${toString(iy)}
        l${toString(vt * cos(theta2))} ${toString(vt * sin(theta2))}`}
        stroke={"#DDF"}
        fill="none"
        strokeWidth={dp(0.4)}
      />
      <path
        d={`
        M${toString(ix)}${toString(iy)}
        l${toString(vt * cos(theta2))} ${toString(vt * sin(theta2))}
        A${toString(_INNER_RADIUS)} ${toString(_INNER_RADIUS)} 0 0 1 ${toString(
            ix + vt2 * cos(theta3),
          )} ${toString(iy + vt2 * sin(theta3))}`}
        stroke="none"
        fill="white"
        fillOpacity="1%"
      />
    </>
  }
}

module SignFrustum = {
  @react.component
  let make = (~center: Coordinates.polarCoord, ~theta1: float, ~sign: string) => {
    open! Belt.Float
    open! Coordinates
    open! SvgHelpers
    let {r: radius, theta: earthTheta} = center
    let ix = radius * cos(earthTheta)
    let iy = radius * sin(earthTheta)
    let b = 2. * (ix * cos(theta1) + iy * sin(theta1))
    let vt = 0.5 * (-.b + sqrt(b * b - 4. * (radius * radius - _INNER_RADIUS * _INNER_RADIUS)))

    let theta2 = theta1 + _PI / 6.
    let b2 = 2. * (ix * cos(theta2) + iy * sin(theta2))
    let vt2 = 0.5 * (-.b2 + sqrt(b2 * b2 - 4. * (radius * radius - _INNER_RADIUS * _INNER_RADIUS)))

    let innerStartCoord = addDisplacementPolar(center, {r: vt, theta: theta1})
    let innerEndCoord = addDisplacementPolar(center, {r: vt2, theta: theta2})

    let outerStartCoord = scalePolar(_OUTER_RADIUS / _INNER_RADIUS, innerStartCoord)
    let outerEndCoord = scalePolar(_OUTER_RADIUS / _INNER_RADIUS, innerEndCoord)

    let textStartCoord = addDisplacementPolar(
      scalePolar(0.8, innerStartCoord),
      scalePolar(0.2, outerStartCoord),
    )
    let textEndCoord = addDisplacementPolar(
      scalePolar(0.8, innerEndCoord),
      scalePolar(0.2, outerEndCoord),
    )

    let textPathId = `txt-${sign}`
    <g onClick={_ => Js.Console.log(sign)}>
      <path
        d={`M${toPolarPoint(innerStartCoord)}
          A${toString(_INNER_RADIUS)} ${toString(_INNER_RADIUS)} 0 0 1 
            ${toPolarPoint(innerEndCoord)}
          L${toPolarPoint(outerEndCoord)}
          A${toString(_OUTER_RADIUS)} ${toString(_OUTER_RADIUS)} 0 0 0 
            ${toPolarPoint(outerStartCoord)}`}
        className={"fill-black hover:fill-white cursor-pointer"}
        fillOpacity="10%"
      />
      <path
        d={`M${toPolarPoint(innerStartCoord)}
            L${toPolarPoint(outerStartCoord)}`}
        stroke="white"
        strokeWidth="0.4"
      />
      <path
        d={`M${toPolarPoint(textStartCoord)}
          A${toString(_TEXT_RADIUS)} ${toString(_TEXT_RADIUS)} 0 0 1 
            ${toPolarPoint(textEndCoord)}`}
        id={textPathId}
        fill="none"
      />
      <text className="fill-white text-[12px] pointer-events-none" textAnchor="middle">
        <textPath xlinkHref={`#${textPathId}`} startOffset="50%"> {React.string(sign)} </textPath>
      </text>
    </g>
  }
}

module Zodiac = {
  @react.component
  let make = (~theta0: float, ~signs: array<string>, ~conformalCenter: Coordinates.polarCoord) => {
    let signCount = Array.length(signs)
    let sliceAngle = 2. * _PI / float(signCount)

    <>
      <filter id="glow">
        <feGaussianBlur result="coloredBlur" stdDeviation="1.0" />
        <femerge>
          <femergenode in_="coloredBlur" />
          <femergenode in_="SourceGraphic" />
        </femerge>
      </filter>
      <g filter="url(#glow)">
        <circle
          cx={dp(0.)}
          cy={dp(0.)}
          r={dp(_OUTER_RADIUS)}
          stroke={"#DDF"}
          strokeWidth={dp(0.4)}
          fill="none"
        />
        <circle
          cx={dp(0.)}
          cy={dp(0.)}
          r={dp(_INNER_RADIUS)}
          stroke={"#DDF"}
          strokeWidth={dp(0.4)}
          fill="none"
        />
        {React.array(
          Belt.Array.mapWithIndex(signs, (i, symbol) => {
            <>
              <SignWedge
                key={symbol} center={conformalCenter} theta2={theta0 + float(i) * sliceAngle}
              />
              <SignFrustum
                center={conformalCenter} theta1={theta0 + float(i) * sliceAngle} sign={symbol}
              />
            </>
          }),
        )}
      </g>
    </>
  }
}
