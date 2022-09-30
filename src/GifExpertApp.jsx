import { useState } from "react";
import { AddCategory, GifGrid } from "./comp";

export const GifExpertApp = () => {
 
  const [categories, setCategories] = useState(['One Punch']);
  
  const onAddCategory = (newCategory) => {
    if ( categories.includes(newCategory) )
      return;
    //console.log(newCategory)
    //setCategories([newCategory, ...categories]);
    setCategories([...categories, newCategory] )
  }

  //console.log(categories);

  return (
    <>
        <h1>GifExpertApp</h1>

        < AddCategory 
          onNewCategory = { (value) => onAddCategory(value) } 
        />
      

      { 
        categories.map( (category) => (
            <GifGrid 
              key = {category} 
              category = {category}
            />
        )) 
      }
      
    </>
  )
}