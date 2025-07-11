// This example demonstrates loading raw binary data from a URL into a buffer and printing its contents.
import playground;

// Load raw binary data from payload.bin into a read-only structured buffer.
[playground::DATA("static/payload.bin")]
StructuredBuffer<uint> dataBuf;

void printMain()
{
    for (uint i = 0; i < 8; ++i)
        print("%u: %u\n", i, dataBuf[i]);
}
