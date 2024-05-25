const minFilterPrice = document.querySelector('.price_filter[name="price-min"]');//тут мы обращаемся к классу и имени inpat
const maxFilterPrice = document.querySelector('.price_filter[name="price-max"]');//тут мы обращаемся к классу и имени inpat
let sortFilterObject = {  // тут мы создаем чистоту кода.чтобы исправно работал
    originalArray: goodsList,// тут мы создаем чистоту кода.чтобы исправно работал
    coveredArray : [],// тут мы создаем чистоту кода.чтобы исправно работал
    isFilter: '',// тут мы создаем чистоту кода.чтобы исправно работал
    isSortMin: 0,// тут мы создаем чистоту кода.чтобы исправно работал
    isSortMax: 0// тут мы создаем чистоту кода.чтобы исправно работал
}// тут мы создаем чистоту кода.чтобы исправно работал
console.log(sortFilterObject);

minFilterPrice.addEventListener('change', () => {  //мы повесили событие,что когда мы выполнили действие но еще без пследствий,то
    sortFilterObject.isSortMin = minFilterPrice.value;

    if(sortFilterObject.isSortMax !== 0){
        sortFilterObject.coveredArray = goodsList.filter(item => item.price > sortFilterObject.isSortMin && item.price < sortFilterObject.isSortMax)
        createList( sortFilterObject.coveredArray);// мы берем массив  и фильтруем его цену так,чтобы она была меньше написанной в inpat 
        console.log(sortFilterObject);
    }else{
        sortFilterObject.coveredArray = goodsList.filter(item => item.price > sortFilterObject.isSortMin)
        createList( sortFilterObject.coveredArray);// мы берем массив  и фильтруем его цену так,чтобы она была меньше написанной в inpat 
        console.log(sortFilterObject);
    }
});
maxFilterPrice.addEventListener('change', () => {
    sortFilterObject.isSortMax = maxFilterPrice.value

    if(sortFilterObject.isSortMin !== 0){
        sortFilterObject.coveredArray = goodsList.filter(item => item.price > sortFilterObject.isSortMin && item.price < sortFilterObject.isSortMax)
        createList( sortFilterObject.coveredArray);// мы берем массив  и фильтруем его цену так,чтобы она была меньше написанной в inpat 
        console.log(sortFilterObject);
    }else{
        sortFilterObject.coveredArray = goodsList.filter(item => item.price < sortFilterObject.isSortMax)
        createList( sortFilterObject.coveredArray);// мы берем массив  и фильтруем его цену так,чтобы она была меньше написанной в inpat 
    }
})
//создали массив
const createList = (productList) => {   //Функция отрисовки элементов массива на странице
    const parentList = document.querySelector('.goods-list'); //Определяем родителя (куда поместим элементы)
    parentList.innerHTML = '';
    productList.forEach(product => {
        const newProduct =`
        <li class="goods-list__single">
            <p class="goods-list__single-title">${product.title}</p>
            <p class="goods-list__single-body">${product.body}</p>
            <p class="goods-list__single-price">${product.price}</p>
        </li>`;
        parentList.insertAdjacentHTML('beforeend', newProduct)
    })
}

createList(goodsList) //Вызов функции