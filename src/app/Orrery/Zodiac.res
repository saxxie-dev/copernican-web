// module Frustum = {
//   @react.component
//   let make = (
//     ~center: (float, float),
//     ~minRadius: float,
//     ~maxRadius: float,
//     ~theta0: float,
//     ~theta1: float,
//   ) => {
//     open! Belt.Float
//     let ix = radius * cos(theta)
//     let iy = -.radius * sin(theta)
//     let b = 2. * (ix * cos(theta2) + iy * sin(theta2))
//     let vt = 0.5 * (-.b + sqrt(b * b - 4. * (radius * radius - 130. * 130.)))
//     let theta3 = theta2 + _PI / 6.
//     let b2 = 2. * (ix * cos(theta3) + iy * sin(theta3))
//     let vt2 = 0.5 * (-.b2 + sqrt(b2 * b2 - 4. * (radius * radius - 130. * 130.)))

//     <path
//       key={toString(theta2)}
//       d={`M${toString(ix)} ${toString(iy)}
//                 l${toString(vt * cos(theta2))} ${toString(vt * sin(theta2))}
//                 A130 130 0 0 1 ${toString(ix + vt2 * cos(theta3))} ${toString(
//           iy + vt2 * sin(theta3),
//         )}
//               `}
//       fill="url(#Zodiac)"
//       fillOpacity={mod(i, 2) == 0 ? "0.4" : "0"}
//     />
//   }
// }

type sign<'a> = {
  id: 'a,
  render: unit => React.element,
  tooltip: unit => React.element,
}

@react.component
let make = (
  ~signs: array<sign<'a>>,
  ~initialAngle: float,
  ~center: (float, float),
  ~radius: float,
  ~selection: option<'a>,
  ~focus: option<'a>,
) => {
  <>
    <mask id="zodiacMask" />
  </>
}

module Shapey = {
  @react.component
  let make = (~props) => {
    <div {...props} />
  }
}
