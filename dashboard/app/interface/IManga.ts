import { ReactNode } from "react";

export interface IcardOverview {
  title: string;
  logo: ReactNode;
  totalManga: number | undefined;
}

export interface ImangaDetail {
  title: string | undefined;
  released: string;
  genres: string[];
  status: string;
}

export interface mangaData {
  mangaData: ImangaDetail[];
}

export interface PaginationProps {
  currentPage: number;
  totalPages: number;
  onPageChange: (page: number) => void;
}

export interface PaginationData {
  current_page: number;
  total_items: number;
  total_pages: number;
}
