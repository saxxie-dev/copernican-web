"use client"
import Image from 'next/image'
import { translateCenterCartesian } from './Calculations/Coordinates.bs';
import { SolarSystem } from './Orrery/Orrery.bs';

export default function Home() {
  return (
    <main className="flex flex-col p-12 h-full overflow-hidden w-full">
      <section className="flex flex-row flex-grow w-full overflow-hidden">
        <div className="flex-grow h-full">
          <SolarSystem.make time={new Date()} />
        </div>
      </section>
    </main>
  )
}
