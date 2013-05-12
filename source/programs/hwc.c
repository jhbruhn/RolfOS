int main(void) {  
  asm volatile ("call *0x0c" : : "S"("Hello, World!\n"));
  
  return 0;
}