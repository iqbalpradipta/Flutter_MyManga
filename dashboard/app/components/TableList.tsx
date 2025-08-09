import React from "react";
import { mangaData } from "../interface/IManga";

function TableList({ mangaData }: mangaData) {
  return (
    <div className="flex flex-col">
      <div className="-m-1.5 overflow-x-auto">
        <div className="p-1.5 min-w-full inline-block align-middle">
          <div className="overflow-hidden">
            <table className="min-w-full divide-y divide-gray-200">
              <thead>
                <tr>
                  <th
                    scope="col"
                    className="px-6 py-3 text-start text-xs font-Bold text-gray-400 uppercase"
                  >
                    Title
                  </th>
                  <th
                    scope="col"
                    className="px-6 py-3 text-start text-xs font-Bold text-gray-400 uppercase"
                  >
                    Release Date
                  </th>
                  <th
                    scope="col"
                    className="px-6 py-3 text-start text-xs font-Bold text-gray-400 uppercase"
                  >
                    Genres
                  </th>
                  <th
                    scope="col"
                    className="px-6 py-3 text-end text-xs font-Bold text-gray-400 uppercase"
                  >
                    Status
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {mangaData.map((value, index) => (
                  <tr key={index}>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-white">
                      {value.title}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-white">
                      {value.released}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-white">
                      {value.genres?.join(", ")}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-end text-sm font-medium">
                      <button
                        type="button"
                        className="inline-flex items-center gap-x-2 text-sm font-semibold rounded-lg border border-transparent text-blue-500 hover:text-blue-800 focus:outline-hidden focus:text-blue-800 disabled:opacity-50 disabled:pointer-events-none"
                      >
                        {value.status}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}

export default TableList;
