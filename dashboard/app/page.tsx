import CardOverview from "./components/CardOverview";
import TableList from "./components/TableList";
import { MdBookmarkAdd, MdBookmarkAdded, MdMenuBook } from "react-icons/md";

export default function Home() {
  return (
    <div className="p-10">
      <p>Welcome to dashboard MangaBal!</p>
      <div className="border-1 rounded-xl border-gray-400 shadow-2xl bg-gray-600">
        <div className="grid grid-cols-3 divide-x-3 divide-dashed divide-gray-200">
          <CardOverview title={"Total Manga"} Logo={<MdMenuBook className="size-15"/>} />
          <CardOverview title={"Manga Ongoing"} Logo={<MdBookmarkAdd className="size-15"/>} />
          <CardOverview title={"Manga Complete"} Logo={<MdBookmarkAdded className="size-15"/>}/>
        </div>
      </div>

      <div className="border-1 rounded-xl mt-5 border-gray-400 shadow-2xl bg-gray-600">
        <div className="p-5">
          <p className="text-gray-100">List Manga</p>
          <p className="text-gray-300 text-sm">List of Manga ready to read!</p>
        </div>
        <TableList />
      </div>
    </div>
  );
}
