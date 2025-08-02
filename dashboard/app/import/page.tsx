import React from 'react'

function Page() {
  return (
    <div className='p-4' >
        <p>Import data JSON to DB</p>
      <form className='border-1 rounded-xl p-5 border-gray-400 shadow-xl bg-gray-600'>
        <label htmlFor="json" className='text-white'>JSON</label> <br />
        <textarea id="json" name="json" rows={10} cols={120} style={{resize: 'none'}} className='shadow-xl rounded-xl border-1 border-white' />
        <button className='border-1 border-white shadow-xl rounded-xl w-25 bg-gray-500 text-white'>Submit</button>
      </form>
    </div>
  )
}

export default Page