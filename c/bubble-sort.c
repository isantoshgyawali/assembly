#include <stdio.h>

int main() {
    int arr[] = {20, 30, 67, 86,52, 94, 55, 82, 34, 33};
    int length = sizeof(arr) / sizeof(arr[0]);
    
    int i, j, temp;
    for(i = 0; i < length; ++i) {
        // comparing adjacent elements
        for(j = 0; j < length - i - 1; ++j) {
            if(arr[j] > arr[j+1]) {
                temp = arr[j];
                arr[j] = arr[j+1];
                arr[j+1] = temp;
            } 
        }
    }

    for(i=0; i < length; ++i){
        printf("%d\n", arr[i]);
    }
}
