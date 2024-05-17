const testObjectArray = [
    {
        id: 1,
        name: 'Anna',
        age: 25,
        order: 'question'
    },
    {
        id: 2,
        name: 'Alex',
        age: 44,
        order: 'answer',
    },   
    {
        id: 2,
        name: 'Alex',
        age: 44,
        order: 'answer',
    }, 
    {
        id: 3,
        name: 'Nina',
        age: 31,
        order: 'question',
    }
];
const testNumberArray = [2,3,1,24,23,54,23,67,8,7,2];
const testStringArray = [ 'orange', 'apple'];

//push добавить элемент в конец массива
testObjectArray.push({id: 4, name: 'Lina', age: 45, order: 'answer',})
// testNumberArray.push(14, 36)
testStringArray.push('banana')
// console.log(testObjectArray);
// console.log(testNumberArray);
// console.log(testStringArray);

//pop удаления элементов из конца массива
// testObjectArray.pop()
// testNumberArray.pop()
// testStringArray.pop()
// console.log(testObjectArray);
// console.log(testNumberArray);
// console.log(testStringArray);

//sort сортирует
console.log(testStringArray.sort());
console.log(testNumberArray.sort((a, b) => a - b));
console.log(testObjectArray.sort((a, b) => a.age - b.age));
console.log(testObjectArray.sort((a, b) => a.name > b.name ? 1 : -1)); //!!!

//filter 
console.log(testObjectArray.filter(item => item.order !== 'answer'));
console.log(testObjectArray.filter(item => item.order === 'answer'));

//find первый подходящий
console.log([testObjectArray.find(item => item.order !== 'answer')]);

//some проверяет условие и возращает true false хотя бы одни подходит
console.log(testObjectArray.some(item => item.address === ''));

//every проверяет условие и возращает true false 
console.log(testObjectArray.every(item => typeof item.id === 'number'));
console.log(testObjectArray.every(item => typeof item.id === 'string'));

//reduce
// console.log(testObjectArray.reduce((acc, item) => {
//     if(!acc.includes(item)){
//         acc.push(item)
//     }

//     return acc;
// }, []));
console.log(testObjectArray.reduce((acc, item) => {
    if(!acc[item.order]){
        acc[item.order] = []
    }
    acc[item.order].push(item)
    return acc;
}, []));

//forEach
testNumberArray.forEach(item => {
    console.log(item);
})
testObjectArray.forEach(item => {
    console.log(item);
})
testStringArray.forEach(item => {
    console.log(item);
})

//concat
console.log(testObjectArray.concat(testNumberArray));

//Строки
const newString = 'lorem ipsum'
//slice
console.log(newString.slice(0, 5));