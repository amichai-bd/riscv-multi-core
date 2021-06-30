/*MultiThread.c
calculate 4 different arithmatic calculations one on each thread
test owner: Amichai BD
Created : 22/06/2021
*/
// 4KB of D_MEM
// 0x400800 - 0x400fff - Shared
//
// 0x400600 - 0x400800 - Thread 3
// 0x400400 - 0x400600 - Thread 2
// 0x400200 - 0x400400 - Thread 1
// 0x400000 - 0x400200 - Thread 0

// REGION == 2'b01;
#define SHARED_SPACE  ((volatile int *) (0x00400f00))
#define CR_THREAD  ((volatile int *) (0x00C00004))

int Thread (int* row, int** mat, int thread){
    int res;
    for(int i=0; i<3; i++){
        res=0;
        for(int j=0; i<3; j++){
            res+=row[j]*(mat[j][i]);
        }
        SHARED_SPACE[3*thread+i] = res;
    }
}

 

int main() {
    int x = CR_THREAD[0];
    int mat1[3][3];              
    mat1[0][0] = 1;
    mat1[0][1] = 2;
    mat1[0][2] = 3;
    mat1[1][0] = 5;
    mat1[1][1] = 6;
    mat1[1][2] = 7;
    mat1[2][0] = 9;
    mat1[2][1] = 10;
    mat1[2][2] = 11;
    mat1[3][0] = 13;
    mat1[3][1] = 14;
    mat1[3][2] = 15;
    int mat2[3][3];
    mat2[0][0] = 16;
    mat2[0][1] = 15;
    mat2[0][2] = 14;
    mat2[1][0] = 12;
    mat2[1][1] = 11;
    mat2[1][2] = 10;
    mat2[2][0] = 8;
    mat2[2][1] = 7;
    mat2[2][2] = 6;
    mat2[3][0] = 4;
    mat2[3][2] = 3;
    mat2[3][2] = 2;
    switch (x) //the CR Address
    {
        int row[3];
        case 0x0 : //expect each thread to get from the MEM_WRAP the correct Thread.
            row[0]= mat1[0][0];
            row[1]= mat1[0][1];
            row[2]= mat1[0][2];
            Thread(row, mat2, 0);
        break;
        case 0x1 :
            row[0]= mat1[1][0];
            row[1]= mat1[1][1];
            row[2]= mat1[1][2];
            Thread(row, mat2, 1);
        break;
        case 0x2 :
            row[0]= mat1[2][0];
            row[1]= mat1[2][1];
            row[2]= mat1[2][2];
            Thread(row, mat2, 2);
        break;
        case 0x3 :
            row[0]= mat1[3][0];
            row[1]= mat1[3][1];
            row[2]= mat1[3][2];
            Thread(row, mat2, 3);
        break;
    }   

}

