export declare enum PaymentGateway {
    RAZORPAY = "RAZORPAY",
    STRIPE = "STRIPE",
    PAYPAL = "PAYPAL"
}
export declare class CreateOrderDto {
    amount: number;
    currency: string;
    gateway: PaymentGateway;
    description: string;
}
