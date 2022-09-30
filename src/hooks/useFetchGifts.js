import { useEffect, useState } from "react";
import { getGifs } from "../helpers/getGifs";

export const useFetchGifts = ( category ) => {
    const [ images, setImages] = useState( [] );
    const [ isLoading, setIsLoading] = useState( true);

    const getImages = async() => {
        const newImages = await getGifs(category);
        setImages(newImages);
        setIsLoading(false);
    }

    useEffect( () => { //Lo unico q hace es llamar el getImage
        getImages();
            
    }, [ ] );

    return {
        images,
        isLoading
    }
}
