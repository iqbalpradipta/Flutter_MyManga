import React, { ReactNode } from "react";
import { FaBook } from "react-icons/fa";
import { IcardOverview } from "../interface/IManga";

function CardOverview({title, logo, totalManga}: IcardOverview ) {
  return (
    <div className="flex">
      <div className="p-4">
        {logo}
      </div>
      <div className="mt-5">
        <div className="text-gray-100">{title}</div>
        <div className="text-gray-300">{totalManga}</div>
      </div>
    </div>
  );
}

export default CardOverview;
