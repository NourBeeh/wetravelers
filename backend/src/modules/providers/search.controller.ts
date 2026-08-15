import { Controller, Post, Body } from '@nestjs/common';
import { FlightSearchDto } from '../../common/dto/flight.search.dto';
import { HotelSearchDto } from '../../common/dto/hotel.search.dto';
import { CarSearchDto } from '../../common/dto/car.search.dto';
import { SearchService } from './search.service';

@Controller('search')
export class SearchController {
  constructor(private readonly searchService: SearchService) {}

  @Post('flights')
  async searchFlights(@Body() dto: FlightSearchDto) {
    return this.searchService.searchFlights(dto);
  }

  @Post('hotels')
  async searchHotels(@Body() dto: HotelSearchDto) {
    return this.searchService.searchHotels(dto);
  }

  @Post('cars')
  async searchCars(@Body() dto: CarSearchDto) {
    return this.searchService.searchCars(dto);
  }
}
