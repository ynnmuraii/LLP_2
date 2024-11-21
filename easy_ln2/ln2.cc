#include <stdio.h>
#include <math.h>

int main() {
    float num = 0.3;

    float ln2 = log(2);
    float log2_result = log(num) / ln2;

    printf("Log2(%f) = %f\n", num, log2_result);

    return 0;
}