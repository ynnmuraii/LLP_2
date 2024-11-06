#include <stdio.h>
#include <math.h>

int main() {
    float num = 5;

    float ln2 = log(2.0);
    float log2_result = log(num) / ln2;

    // Вывод результата
    printf("Log2(%f) = %f\n", num, log2_result);

    return 0;
}