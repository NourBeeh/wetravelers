import { NuiteeService } from './src/modules/nuitee/nuitee.service';

async function test() {
  const service = new NuiteeService({ get: (k: string) => process.env[k] } as any);
  console.log('Testing Nuitee API...');
  console.log('API Key exists:', !!process.env.NUITEE_API_KEY);
  
  const result = await service.searchHotels({
    city: 'Cairo',
    checkIn: new Date('2026-09-10'),
    checkOut: new Date('2026-09-15'),
    guests: 2,
  });
  
  console.log('Success:', result.success);
  console.log('Results count:', result.data?.length || 0);
  console.log('Error:', result.error?.slice(0, 150) || 'none');
  
  if (result.data?.[0]) {
    console.log('First hotel:', JSON.stringify(result.data[0]).slice(0, 300));
  }
}

test().catch(console.error);
