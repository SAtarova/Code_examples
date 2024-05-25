const resetFilters = document.querySelector('.reset');
const sortCallButton = document.querySelector('.action-block__sort_default');
const filterButtons = document.querySelectorAll('.sort-list__item');
const minPrice = document.querySelector('.price_filter[name="price-min"]');
const maxPrice = document.querySelector('.price_filter[name="price-max"]');
const goodsParent = document.querySelector('.goods-list');
const goodsList = [
    {
        id: 1,
        title: 'Solar Power Bank',
        body: 'Portable solar power bank with a 20,000mAh capacity. Perfect for outdoor adventures and emergencies. Charges multiple devices simultaneously with dual USB ports.',
        price: 49.99
    },
    {
        id: 2,
        title: 'Wireless Earbuds Pro',
        body: 'Premium wireless earbuds with noise-cancellation technology. Enjoy crystal-clear sound and up to 24 hours of battery life. Comes with a compact charging case.',
        price: 89.99
    },
    {
        id: 3,
        title: 'Smart Fitness Tracker',
        body: 'Advanced fitness tracker with heart rate monitor, sleep analysis, and step counter. Syncs with your smartphone to provide real-time health insights.',
        price: 39.99
    },
    {
        id: 4,
        title: 'LED Desk Lamp',
        body: 'Modern LED desk lamp with adjustable brightness levels and color temperatures. Features a built-in USB charging port and touch-sensitive controls.',
        price: 29.99
    },
    {
        id: 5,
        title: 'Bluetooth Speaker',
        body: 'Waterproof Bluetooth speaker with powerful bass and 360-degree sound. Perfect for parties, outdoor activities, and poolside gatherings. Up to 12 hours of playtime.',
        price: 59.99
    },
    {
        id: 6,
        title: 'Ergonomic Office Chair',
        body: 'High-back ergonomic office chair with lumbar support and adjustable armrests. Designed for maximum comfort during long work sessions. Breathable mesh backrest.',
        price: 129.99
    },
    {
        id: 7,
        title: '4K Action Camera',
        body: 'Ultra HD 4K action camera with waterproof casing and wide-angle lens. Ideal for capturing high-quality videos and photos during extreme sports and adventures.',
        price: 99.99
    },
    {
        id: 8,
        title: 'Smart Home Hub',
        body: 'Central smart home hub that connects and controls all your smart devices. Compatible with voice assistants like Alexa and Google Assistant. Easy setup and management.',
        price: 79.99
    },
    {
        id: 9,
        title: 'Electric Standing Desk',
        body: 'Adjustable electric standing desk with programmable height settings. Sturdy construction with a spacious work surface. Improves posture and productivity.',
        price: 299.99
    },
    {
        id: 10,
        title: 'Memory Foam Pillow',
        body: 'Hypoallergenic memory foam pillow with cooling gel technology. Provides optimal neck and head support for a restful night\'s sleep. Machine washable cover.',
        price: 34.99
    }
];
let sortFilterObject = {
    originalArray: goodsList, convertedArray: [],
    isFilter: '', isSortMin: 0, isSortMax: 0
};

sortCallButton.addEventListener('click', () => {
    document.querySelector('.sort-list').classList.toggle('displayShow');
});

const createGoods = (productsArray) => {
    goodsParent.innerHTML = '';
    productsArray.forEach(product => {
        const item = `
            <li class="goods-list__single">
                <p class="goods-list__single-title">${product.title}</p>
                <p class="goods-list__single-body">${product.body}</p>
                <p class="goods-list__single-price">${product.price}</p>
            </li>
        `;
        goodsParent.insertAdjacentHTML('beforeend', item);
    });
};

const filterFunction = (filterName) => {
    if(filterName === 'By name'){
        sortFilterObject.convertedArray.length === 0
            ? sortFilterObject.convertedArray = sortFilterObject.originalArray.sort((a, b) => a.title > b.title ? 1 : -1)
            : sortFilterObject.convertedArray = sortFilterObject.convertedArray.sort((a, b) => a.title > b.title ? 1 : -1);
        sortFilterObject.isFilter = filterName;
    }else if(filterName === 'By body'){
        sortFilterObject.convertedArray.length === 0
            ? sortFilterObject.convertedArray = sortFilterObject.originalArray.sort((a, b) => a.body > b.body ? 1 : -1)
            : sortFilterObject.convertedArray = sortFilterObject.convertedArray.sort((a, b) => a.body > b.body ? 1 : -1);
        sortFilterObject.isFilter = filterName;
    }else if(filterName === 'By price'){
        sortFilterObject.convertedArray.length === 0
            ? sortFilterObject.convertedArray = sortFilterObject.originalArray.sort((a, b) => a.price - b.price)
            : sortFilterObject.convertedArray = sortFilterObject.convertedArray.sort((a, b) => a.price - b.price);
        sortFilterObject.isFilter = filterName;
    }
    createGoods(sortFilterObject.convertedArray);
};

filterButtons.forEach(singleFilterButton => {
    singleFilterButton.addEventListener('click', (e) => {
        document.querySelector('.sort-list').classList.toggle('displayShow');
        filterFunction(e.target.textContent);
    });
});

minPrice.addEventListener('change', (e) => {
    sortFilterObject.isSortMin = parseInt(e.target.value);

    if(sortFilterObject.isSortMin <= sortFilterObject.isSortMax || sortFilterObject.isSortMax === 0){
        if(sortFilterObject.isSortMax !== 0){
            sortFilterObject.convertedArray = sortFilterObject.originalArray.filter(item => item.price > sortFilterObject.isSortMin && item.price < sortFilterObject.isSortMax);
            filterFunction(sortFilterObject.isFilter);
        }else{
            sortFilterObject.convertedArray = sortFilterObject.originalArray.filter(item => item.price > sortFilterObject.isSortMin);
            filterFunction(sortFilterObject.isFilter);
        }
    }else{ alert('Error Min'); }
});

maxPrice.addEventListener('change', (e) => {
    sortFilterObject.isSortMax = parseInt(e.target.value);

    if(sortFilterObject.isSortMax >= sortFilterObject.isSortMin){
        if(sortFilterObject.isSortMin !== 0){
            sortFilterObject.convertedArray = sortFilterObject.originalArray.filter(item => item.price > sortFilterObject.isSortMin && item.price < sortFilterObject.isSortMax);
            filterFunction(sortFilterObject.isFilter);
        }else{
            sortFilterObject.convertedArray = sortFilterObject.originalArray.filter(item => item.price < sortFilterObject.isSortMax);
            filterFunction(sortFilterObject.isFilter);
        }
    }else{ alert('Error Max'); }
});

resetFilters.addEventListener('click', () => {
    createGoods(sortFilterObject.originalArray);
    minPrice.value = '';
    maxPrice.value = '';
});

createGoods(goodsList);