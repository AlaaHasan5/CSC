export default function Button() {
  return (
    <div className="flex items-center">
        <button type="button" className="me-3 rounded bg-black text-white py-1.5 px-4" onClick={() => {console.log("Connected");}}>
            Connect Metamask
        </button>
    </div>
  )
}
