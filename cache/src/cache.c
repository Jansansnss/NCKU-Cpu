#include<stdio.h>
#include<stdlib.h>
#include<time.h>

int *Cache;
int *Cache_touch;
int cache_size = 0; //kb    num_of_blocks == input * 1024 * 16
int block_size = 0; //byte 
int associativity = 0;  //0 : direct-mapped, 1 : four-way set associative, 2 : fully associative.
int replace_algorithm = 0;  //0 : FIFO, 1 : LRU, 2 : your policy.
int tag_size = 0;
int offset_size = 0;
unsigned int accesses = 0;

int num_of_blocks = 0;
int arr[4];
char input_string[]="";
int replace_counter = 0;

int log_2(int num);
int Hit_or_Miss();
void init_cache();
void init_cache_touch();

FILE *fpIn ,*fpOut;

int main(int argc, char *argv[])
{
    srand( time(NULL) );
    /*
    The 1st line specifies the cache size (kb).
    The 2nd line specifies the block size (byte).
    The 3rd line specifies the associativity. 
    The 4th line specifies the Replace algorithm.
    The rest of the test case is a trace of memory accesses executed from some benchmark program.
    */
    /*
        Q1--------------------Input----------------------------
        1024    kb      = 1,048,576 bytes =     16,777,216 bits
        16      byte    = 128       bits
        0       direct-mapped
        0       FIFO
        0xbfa437cc 101111111010 | 0100001101111100 | 1100
        0xbfa437c8 101111111010 | 0100001101111100 | 1000
        0xbfa437c4 101111111010 | 0100001101111100 | 0100
        0xbfa437c0 101111111010 | 0100001101111100 | 0000
        0xbfa437bc 101111111010 | 0100001101111011 | 1100
        0xbfa437b8 101111111010 | 0100001101111011 | 1000
        0xb80437b8 101110000000 | 0100001101111011 | 1000--
        0xb8043794 101110000000 | 0100001101111001 | 0100
        0xb80437c8 101110000000 | 0100001101111100 | 1000--
        0xb80437cc 101110000000 | 0100001101111100 | 1100

        __ __ __
        12 16 4
        Q1--------------------Output----------------------------
        -1
        -1
        -1
        -1
        -1
        -1
        3066
        -1
        3066
        -1
        ---------------------------------------------------------
        num_of_blocks  = 65,536 (2^16)

    */

    fpIn = fopen(argv[1],"r");

    fscanf(fpIn ,"%d", &cache_size); 
    fscanf(fpIn ,"%d", &block_size);
    fscanf(fpIn , "%d", &associativity);
    fscanf(fpIn , "%d", &replace_algorithm);

    num_of_blocks = cache_size * 1024 / block_size;
    offset_size = log_2(block_size);
    if (associativity ==0)
        tag_size = 32 - log_2(num_of_blocks) - offset_size;
    else if (associativity == 1)
        tag_size = 32 - log_2(num_of_blocks/4) - offset_size;
    else
        tag_size = 32 - offset_size;
    init_cache();
    
    fpOut = fopen(argv[2],"w");

    while(fscanf(fpIn, "%x", &accesses)!=EOF)
    {
        Hit_or_Miss();
    }
    fclose(fpIn);
    fclose(fpOut);
    
    return 0;
}

int log_2(int num)
{
    int counter = 0;
    for (; num>1 ;counter++)
        num /= 2;
    return counter;
}

void init_cache()
{
    if(associativity ==0)
    {
        Cache = malloc(num_of_blocks * sizeof(int));
        if( Cache == NULL )
        {
            printf("Error: malloc failure\n");
        }
        for(int i =0; i<num_of_blocks;i++)
        {
            Cache[i] = -1;
        }
    }
    else if(associativity ==1)
    {
        Cache = malloc(num_of_blocks * sizeof(int));
        Cache_touch = malloc(num_of_blocks * sizeof(int));
        if( Cache == NULL || Cache_touch == NULL)
        {
            printf("Error: malloc failure\n");
        }
        for(int i = 0; i<num_of_blocks/4;i++)
        {
            for(int j = 0; j<4;j++)
            {
                *(Cache+i*4+j) = -1;
                *(Cache_touch+i*4+j) = j;
            }
        }
    }
    else //associativity ==2
    {
        Cache = malloc(num_of_blocks * sizeof(int));
        Cache_touch = malloc(num_of_blocks * sizeof(int));
        if( Cache == NULL || Cache_touch == NULL)
        {
            printf("Error: malloc failure\n");
        }
        for(int i = 0; i < num_of_blocks;i++)
        {
            *(Cache+i) = -1;
            *(Cache_touch+i) = i;
        }
    }
}

int Hit_or_Miss()
{
    int Cache_index = (accesses << tag_size ) >> (offset_size + tag_size);
    //printf("%d\n",Cache_index);
    int tag = accesses >> (32 - tag_size);
    switch (associativity)
    {
    case 0:
    //direct-mapped
        if(Cache[Cache_index] == tag)
            //Hit
        {
            fprintf(fpOut, "-1\n");
            //printf("-1\n");
        }
        else
        {
            int previous_tag = Cache[Cache_index];
            Cache[Cache_index] = tag;
            fprintf(fpOut, "%d\n",previous_tag);
            //printf("%d\n",previous_tag);
        }
        break;
    case 1:
    //four-way set associative
        if (replace_algorithm == 0)
        //FIFO Cache_touch 越早進來數字越小
        {
            for(int i;i<4;i++)
            {
                if(*(Cache+Cache_index*4+i) == tag)
                //Hit
                {
                    fprintf(fpOut, "-1\n");
                    //printf("-1\n");
                    return 0;
                }
            }
            int previous_tag = -1;
            for(int i;i<4;i++)
            {
                *(Cache_touch+Cache_index*4+i) -= 1;
                if( *(Cache_touch+Cache_index*4+i) == -1)
                {
                    *(Cache_touch+Cache_index*4+i) =3;
                    previous_tag = *(Cache+Cache_index*4+i);
                    *(Cache+Cache_index*4+i) = tag;
                }
            }
            fprintf(fpOut, "%d\n",previous_tag);
            //printf("%d\n",previous_tag);
        }
        else if (replace_algorithm == 1)
        //LRU Cache_touch 越早進來數字越小
        {
            for(int i=0;i<4;i++)
            {
                if(*(Cache+Cache_index*4+i) == tag)
                //Hit
                {
                    for(int j=0;j<4;j++)
                    {
                        if(*(Cache_touch+Cache_index*4+j) > *(Cache_touch+Cache_index*4+i))
                        {
                            *(Cache_touch+Cache_index*4+j) -=1;
                        }
                    }
                    *(Cache_touch+Cache_index*4+i) = 3;
                    fprintf(fpOut, "-1\n");
                    //printf("-1\n");
                    return 0;
                }
            }
            int previous_tag = *(Cache+Cache_index*4);
            for(int i=1;i<4;i++)
            {
                *(Cache_touch+Cache_index*4+i) -= 1;
                if(*(Cache_touch+Cache_index*4+i) == -1)
                {
                    *(Cache_touch+Cache_index*4+i) = 3;
                    previous_tag = *(Cache+Cache_index*4+i);
                    *(Cache+Cache_index*4+i) = tag;
                }
            }
            fprintf(fpOut, "%d\n",previous_tag);
            //printf("%d\n",previous_tag);
        }
        else//replace_algorithm == 2 //FILO
        {
            for(int i=0;i<4;i++)
            {
                if(*(Cache+Cache_index*4+i) == tag)
                //Hit
                {
                    fprintf(fpOut, "-1\n");
                    return 0;
                }
            }
            for(int i=0;i<4;i++)
            {
                if(*(Cache+Cache_index*4+i) == -1)
                {
                    fprintf(fpOut, "-1\n");
                    *(Cache+Cache_index*4+i) = tag;
                    return 0;
                }
            }
            int r = rand()%4;
            int previous_tag = *(Cache+Cache_index*4+r);
            *(Cache+Cache_index*4+r) = tag;
            fprintf(fpOut, "%d\n",previous_tag);
        }
    
        break;
    case 2:
    //fully associative
        if (replace_algorithm == 0)//FIFO
        {
            for(int i =0; i<num_of_blocks;i++)
            {
                if(*(Cache+i) == tag)
                //Hit
                {
                    fprintf(fpOut, "-1\n");
                    //printf("-1\n");
                    return 0;
                }
            }
            for(int i =0; i<num_of_blocks;i++)
            {
                *(Cache_touch+i) -= 1;
                if(*(Cache_touch+i) == -1)
                {
                    int previous_tag = *(Cache+i);
                    *(Cache+i) = tag;
                    fprintf(fpOut, "%d\n",previous_tag);
                    //printf("%d\n",previous_tag);
                }
            }
        }
        else if (replace_algorithm == 1)//LRU
        {
            for(int i=0;i<num_of_blocks;i++)
            {
                if(*(Cache+i) == tag)
                //Hit
                {
                    for(int j=0;j<num_of_blocks;j++)
                    {
                        if(*(Cache_touch+j) > *(Cache_touch+i))
                        {
                            *(Cache_touch+j) -=1;
                        }
                    }
                    *(Cache_touch+i) = num_of_blocks - 1;
                    fprintf(fpOut, "-1\n");
                    return 0;
                }
            }
            int previous_tag = *Cache;
            for(int i=0;i<num_of_blocks;i++)
            {
                *(Cache_touch+i) -= 1;
                if(*(Cache_touch+i) == -1)
                {
                    *(Cache_touch+i) = num_of_blocks - 1;
                    previous_tag = *(Cache+i);
                    *(Cache+i) = tag;
                }
            }
            fprintf(fpOut, "%d\n",previous_tag);
        }
        else//My
        {
            for(int i=0;i<num_of_blocks;i++)
            {
                if(*(Cache+i) == tag)
                //Hit
                {
                    fprintf(fpOut, "-1\n");
                    return 0;
                }
            }
            for(int i=0;i<num_of_blocks;i++)
            {
                if(*(Cache+i) == -1)
                {
                    fprintf(fpOut, "-1\n");
                    *(Cache+i) = tag;
                    return 0;
                }
            }
            int r = rand()%num_of_blocks;
            int previous_tag = *(Cache+r);
            *(Cache+r) = tag;
            fprintf(fpOut, "%d\n",previous_tag);
        }
        break;
    default:
        break;
    }
    return 0;
}
