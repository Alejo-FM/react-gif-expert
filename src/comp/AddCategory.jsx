import { useState } from "react"

export const AddCategory = ( {onNewCategory} ) => {

    const [inputValue, setInputValue] = useState('');

    const onInputChange = ({target}) => {
        //console.log(event)
        setInputValue(target.value)
        //setInputValue('');
    }

    const onSubmit = (event ) => {
        event.preventDefault();
        if ( inputValue.trim().length <= 1) return;
        
        setInputValue('');
        onNewCategory( inputValue.trim() );
        //setCategories( categories => [inputValue, ...categories ])
        
    }

    return (
        <form onSubmit={ onSubmit }> 
            <input 
                type= "text"
                placeholder = "Buscar Gifs"
                value={ inputValue }
                onChange={ onInputChange }
            /> 
        </form>


    )
}
