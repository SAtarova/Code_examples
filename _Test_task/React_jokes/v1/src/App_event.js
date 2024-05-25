const listJokes = []
const FillStructure = (result) => {
    const jokeStructure = {}

    jokeStructure.type = result.type
    jokeStructure.setup = result.setup
    jokeStructure.punchline = result.punchline
    jokeStructure.id = result.id

    listJokes.push(jokeStructure)
    console.log(listJokes)
}
const handleClick = (e) => {
    e.preventDefault()
    fetch('https://official-joke-api.appspot.com/random_joke', {method: 'GET'})
        .then((res) => res.json())
        .then((result) => {
            FillStructure(result)
        })
}
export default handleClick