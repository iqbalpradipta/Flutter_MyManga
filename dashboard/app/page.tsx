'use client'

import axios from "axios";
import CardOverview from "./components/CardOverview";
import TableList from "./components/TableList";
import { MdBookmarkAdd, MdBookmarkAdded, MdMenuBook } from "react-icons/md";
import { useEffect, useState } from "react";
import Pagination  from "./components/Pagination";
import { PaginationData } from "./interface/IManga";

export default function Home() {
  const [paginationInfo, setPaginationInfo] = useState<PaginationData | null>(null);
  const [mangaData, setMangaData] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);

  useEffect(() => {
    const fetchData = async (page: number) => {
      try {
        const response = await axios.get(
          `http://localhost:8000/api/v1/comic?page=${page}&limit=${10}`
        );
        
        setPaginationInfo(response.data.pagination);
        setMangaData(response.data.data);
      } catch (error) {
        console.log(error);
      }
    };

    fetchData(currentPage);
  }, [currentPage]);

  const handlePageChange = (page: number) => {
    setCurrentPage(page);
  };

  return (
    <div className="p-10">
      <p>Welcome to dashboard MangaBal!</p>
      <div className="border-1 rounded-xl border-gray-400 shadow-2xl bg-gray-600">
        <div className="grid grid-cols-3 divide-x-3 divide-dashed divide-gray-200">
          <CardOverview
            title={"Total Manga"}
            logo={<MdMenuBook className="size-15" />}
            totalManga={paginationInfo?.total_items || 0}
          />
          <CardOverview
            title={"Manga Ongoing"}
            logo={<MdBookmarkAdd className="size-15" />}
            totalManga={0}
          />
          <CardOverview
            title={"Manga Complete"}
            logo={<MdBookmarkAdded className="size-15" />}
            totalManga={0}
          />
        </div>
      </div>

      <div className="border-1 rounded-xl mt-5 border-gray-400 shadow-2xl bg-gray-600">
        <div className="p-5">
          <p className="text-gray-100">List Manga</p>
          <p className="text-gray-300 text-sm">List of Manga ready to read!</p>
        </div>
        <TableList mangaData={mangaData} />
      </div>

      {paginationInfo && (
        <Pagination
          currentPage={paginationInfo.current_page}
          totalPages={paginationInfo.total_pages}
          onPageChange={handlePageChange}
        />
      )}
    </div>
  );
}