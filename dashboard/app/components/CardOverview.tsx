import React, { ReactNode } from "react";
import { FaBook } from "react-icons/fa";

interface Props {
    title: string
    Logo: ReactNode
}

function CardOverview({title, Logo}: Props ) {
  return (
    <div className="flex">
      <div className="p-4">
        {Logo}
      </div>
      <div className="mt-5">
        <div className="text-gray-100">{title}</div>
        <div className="text-gray-300">1000</div>
      </div>
    </div>
  );
}

export default CardOverview;
