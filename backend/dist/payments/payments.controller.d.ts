import { PaymentsService } from './payments.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { VerifyPaymentDto } from './dto/verify-payment.dto';
export declare class PaymentsController {
    private readonly paymentsService;
    constructor(paymentsService: PaymentsService);
    createOrder(dto: CreateOrderDto, req: any): Promise<{
        gateway: string;
        orderId: any;
        amount: any;
        currency: any;
        key: string;
        message?: undefined;
    } | {
        gateway: import("./dto/create-order.dto").PaymentGateway;
        orderId: string;
        amount: number;
        currency: string;
        message: string;
        key?: undefined;
    }>;
    verifyPayment(dto: VerifyPaymentDto): Promise<{
        status: string;
        message: string;
        orderId: string;
        paymentId: string;
    }>;
}
